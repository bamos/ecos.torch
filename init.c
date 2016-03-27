#include <ecos.h>

#include <TH/TH.h>

int numNonzero(THDoubleTensor *X) {
  double *X_ = THDoubleTensor_data(X);
  long sz = X->size[0] * X->size[1];
  int nnz = 0;
  for (auto i = 0; i < sz; i++) {
    if (X_[i] != 0) {
      nnz += 1;
    }
  }
  return nnz;
}

void denseToCCS(THDoubleTensor *X,
                pfloat **val, idxint **col_ptr, idxint **row_idx) {
  double *X_ = THDoubleTensor_data(X);
  int nnz = numNonzero(X);

  int nRow = X->size[0];
  int nCol = X->size[1];

  *val = (pfloat *) malloc(sizeof(pfloat)*nnz);
  *row_idx = (idxint *) malloc(sizeof(idxint)*nnz);
  *col_ptr = (idxint *) malloc(sizeof(idxint)*(nCol+1));

  int k = 0;
  for (auto j = 0; j < nCol; j++) {
    (*col_ptr)[j] = k;
    for (auto i = 0; i < nRow; i++) {
      double Xi = X_[i*nCol+j];
      if (Xi != 0) {
        (*val)[k] = Xi;
        (*row_idx)[k] = i;
        k += 1;
      }
    }
  }
  (*col_ptr)[nCol] = k;
}

int solveLP(THDoubleTensor *rx, THDoubleTensor *c,
            THDoubleTensor *A, THDoubleTensor *b,
            THDoubleTensor *G, THDoubleTensor *h,
            int verbose) {
  if (A) {
    THArgCheck(A->size[0] == b->size[0], 2, "A and b incompatible.");
    THArgCheck(A->size[1] == c->size[0], 2, "A and c incompatible.");
  }
  if (A && G) {
    THArgCheck(A->size[1] == G->size[1], 2, "A and G incompatible.");
  }
  if (G) {
    THArgCheck(G->size[0] == h->size[0], 4, "G and h incompatible.");
    THArgCheck(G->size[1] == c->size[0], 4, "G and c incompatible.");
  }

  int n; // Number of primal variables.
  int m; // Number of inequality constraints.
  if (G) {
    n = G->size[1];
    m = G->size[0];
  } else {
    n = A->size[1];
    m = 0;
  }

  int p = 0; // Number of equality constraints.
  if (A) {
    p = A->size[0];
  }
  int l = m; // Dimension of the positive orthant.
  int ncones = 0; // Number of second-order cones present in problem.
  void *q = 0; // Array of length ncones;
               // q[i] defines the dimension of the cone i.
  int e = 0; // Number of exponential cones present in problem.

  // Arrays for matrix G in column compressed storage (CCS).
  pfloat *Gpr = 0;
  idxint *Gjc = 0, *Gir = 0;
  if (G) {
    denseToCCS(G, &Gpr, &Gjc, &Gir);
  }

  // Arrays for matrix A in column compressed storage (CCS).
  // Can be NULL if no equality constraints are present.
  pfloat *Apr = 0;
  idxint *Ajc = 0, *Air = 0;
  if (A) {
    denseToCCS(A, &Apr, &Ajc, &Air);
  }

  pfloat *c_ = THDoubleTensor_data(c); // Array of length n.

  pfloat *h_ = 0; // Array of length m.
  if (h) {
    h_ = THDoubleTensor_data(h);
  }

  // Array of length p. Can be NULL if no equality constraints are present.
  pfloat *b_ = 0;
  if (b) {
    b_ = THDoubleTensor_data(b);
  }

  pwork* ecosWork = ECOS_setup(n, m, p, l, ncones, q, e,
                               Gpr, Gjc, Gir,
                               Apr, Ajc, Air,
                               c_, h_, b_);
  ecosWork->stgs->verbose = verbose;
  idxint status = ECOS_solve(ecosWork);

  pfloat* x = THDoubleTensor_data(rx);
  memcpy(x, ecosWork->x, sizeof(double)*n);

  ECOS_cleanup(ecosWork, 0);
  return status;
}
