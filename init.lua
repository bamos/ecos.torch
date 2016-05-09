local torch = require 'torch'
local argcheck = require 'argcheck'

local M = {}

local ffi = require 'ffi'
ffi.cdef [[
int ETsolve(THDoubleTensor *rx, THDoubleTensor *c,
          THDoubleTensor *A, THDoubleTensor *b,
          THDoubleTensor *G, THDoubleTensor *h,
          THIntTensor *SOcones, int nExpCones,
          int verbose);
]]

local clib = ffi.load(package.searchpath('libecos', package.cpath))

local solveCheck = argcheck{
   pack=true,
   {name='c', type='torch.DoubleTensor'},
   {name='A', type='torch.DoubleTensor', opt=true},
   {name='b', type='torch.DoubleTensor', opt=true},
   {name='G', type='torch.DoubleTensor', opt=true},
   {name='h', type='torch.DoubleTensor', opt=true},
   {name='SOcones', type='torch.IntTensor', opt=true},
   {name='nExpCones', type='number', opt=true, default=0},
   {name='verbose', type='number', opt=true, default=0}
}
function M.solve(...)
   local args = solveCheck(...)
   local A_, b_, G_, h_
   local c_ = args.c:cdata()
   if args.A then
      A_ = args.A:cdata()
      b_ = args.b:cdata()
   end
   if args.G then
      G_ = args.G:cdata()
      h_ = args.h:cdata()
   end
   local q_
   if args.SOcones then
      q_ = args.SOcones:cdata()
   end
   if args.SOcones or args.nExpCones > 0 then
      print [[
======
ecos.torch warning:

Second order and exponential cones have not been validated.
If you are interested in using these please join our discussion at
https://github.com/bamos/ecos.torch/issues/1
======
]]
   end
   local rx = torch.DoubleTensor(args.c:size(1))
   local status = clib.ETsolve(rx:cdata(), c_, A_, b_,
                               G_, h_, q_, args.nExpCones, args.verbose)
   return status, rx
end

return M
