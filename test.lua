#!/usr/bin/env th

require 'torch'
torch.setdefaulttensortype('torch.DoubleTensor')

local ecos = require 'ecos'

local tester = torch.Tester()
local ecosTest = torch.TestSuite()

local eps = 1e-5

function ecosTest.SmallLP()
   local G = torch.Tensor{{-1, 1}, {-1, -1}, {0, -1}, {1, -2}}
   local h = torch.Tensor{1.0, -2.0, 0.0, 4.0}
   local c = torch.Tensor{2.0, 1.0}
   local optX = torch.Tensor{0.5, 1.5}

   local status, x = ecos.solveLP{c=c, G=G, h=h}
   tester:asserteq(status, 0, 'Nonzero status: ' .. status)
   tester:assertTensorEq(x, optX, eps, 'Invalid optimal value.')
end

tester:add(ecosTest)
tester:run()
