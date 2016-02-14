defmodule KidsCheckin.PageView do
  use KidsCheckin.Web, :view

  def count(color, classes) do
    found = Enum.find(classes, fn class -> class["color"] == color end)
    found["count"]
  end

  def open_close(color, classes) do
    found = Enum.find(classes, fn class -> class["color"] == color end)
    case found["count"] < found["max"] do
      true -> "Open"
      false -> "Full"
    end
  end
end
