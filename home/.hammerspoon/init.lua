-- Move focused window to the screen to the right
hs.hotkey.bind({"ctrl", "option", "cmd"}, "Right", function()
  local win = hs.window.focusedWindow()
  if win then
    win:moveOneScreenEast(false, true)
  end
end)

-- Move focused window to the screen to the left
hs.hotkey.bind({"ctrl", "option", "cmd"}, "Left", function()
  local win = hs.window.focusedWindow()
  if win then
    win:moveOneScreenWest(false, true)
  end
end)
