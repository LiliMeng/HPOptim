require 'torch'
require 'nn'
require 'cephes'
--local HPOptim = require('/HPOptim/HPOptim.lua')


HPOptim.init("/home/toor/Desktop/HPOptim")
HPOptim.clean()
HPOptim.findHP(420)

----------------------- Test Architecture --------------------------------

-----------------------------------------
function getTableFromTensor(teData, nInputs, nOutputs)

    local train_X = teData[1] -- take the first two columns as X
    local train_y = teData[2] -- take the last column as y

   local tableData = {}
   function tableData:size() return train_X[1]:size(1) end

   for i=1, 100 do
     tableData[i] = { train_X:narrow(1,i,1), train_y:narrow(1,i,1) }
   end

   return tableData
end
-----------------------------------------


local train_data = torch.load("data/b_uniErr_train.txt", 'ascii')
local test_data = torch.load("data/b_uniErr_test.txt", 'ascii')


-- Input/Output Nodes
local nInputs = 2
local nOutputs = 1
local dataset_train = getTableFromTensor(train_data, nInputs, nOutputs)

-- define the FNN
local mlp = nn.Sequential()

mlp:add(nn.Linear(nInputs, HPOptim.numHidden1))
mlp:add(nn.Tanh())
mlp:add(nn.Linear(HPOptim.numHidden1, nOutputs))



-- Train the dataset
local criterion = nn.MSECriterion()
local trainer = nn.StochasticGradient(mlp, criterion)
trainer.maxIteration = 400
--trainer.learningRate = 0.01
trainer.verbose = false
trainer:train(dataset_train)

local test_X = {}
local test_y = {}
for i=1, 10 do
test_X[i] = test_data[1]:narrow(1,i,1)
test_y[i] = test_data[2]:narrow(1,i,1)
end

local test_y_pred = {}
for k,v in pairs(test_X) do
		test_y_pred[k] = mlp:forward(v)
end

local mse_arr = {}
local mse_avg = 0
for k,v in pairs(test_y) do
		mse_arr[k] = criterion:forward(test_y_pred[k], test_y[k])
		mse_avg = mse_avg + mse_arr[k]
	print("Test MSE:" .. mse_arr[k] )
end

mse_avg = mse_avg/10

print(mse_avg)