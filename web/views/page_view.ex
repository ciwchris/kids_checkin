defmodule KidsCheckin.PageView do
  use KidsCheckin.Web, :view

  def count(color, classes) do
    found = Enum.find(classes, fn class -> class["color"] == color end)
    found["count"]
  end
end
