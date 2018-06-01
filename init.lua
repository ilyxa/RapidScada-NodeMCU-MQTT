FileToExecute="user.lua"
l = file.list()
for k,v in pairs(l) do
  if k == FileToExecute then
    print("*** You've got 1 sec to stop timer ***")
    tmr.alarm(0, 1000, 0, function()
      print("Executing ".. FileToExecute)
      dofile(FileToExecute)
    end)
  end
end
