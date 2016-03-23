local argcheck = require 'argcheck'

local M = {}

local ffi = require 'ffi'
ffi.cdef [[
   int solveLP(THDoubleTensor *rx, THDoubleTensor *c,
               THDoubleTensor *A, THDoubleTensor *b,
               THDoubleTensor *G, THDoubleTensor *h);
]]

local clib = ffi.load(package.searchpath('libecos', package.cpath))

local solveLPcheck = argcheck{
   pack=true,
   help=[[
Solve a linear program of the form:

  minimize    c^T x
  subject to  Ax = b
              Gx <= h
]],
   {name='c', type='torch.DoubleTensor'},
   {name='A', type='torch.DoubleTensor', opt=true},
   {name='b', type='torch.DoubleTensor', opt=true},
   {name='G', type='torch.DoubleTensor', opt=true},
   {name='h', type='torch.DoubleTensor', opt=true}
}
function M.solveLP(...)
   local args = solveLPcheck(...)
   local A_, b_, G_, h_
   if not args.A then
      A_ = nil
      b_ = nil
   else
      A_ = args.A:cdata()
      b_ = args.b:cdata()
   end
   if not args.G then
      G_ = nil
      h_ = nil
   else
      G_ = args.G:cdata()
      h_ = args.h:cdata()
   end
   c_ = args.c:cdata()
   local rx = torch.DoubleTensor(args.c:size(1))
   local status = clib.solveLP(rx:cdata(), c_, A_, b_, G_, h_)
   return status, rx
end

return M
