defmodule KidsCheckin.PageView do
  use KidsCheckin.Web, :view

  def count(color, classes) do
    found = Enum.find(classes, fn class -> class["color"] == color end)
    found["count"]
  end

  def open_close(color, classes) do
    found = Enum.find(classes, fn class -> class["color"] == color end)
    case found["count"] < found["max"] do
      false -> "Full"
      _ -> "Open"
    end
  end

  def open_close_abr(color, classes, location) do
    case open_close(color, classes) do
      "Full" when location == "left" -> "Fu"
      "Full" -> "ll"
      "Open" when location == "left" -> "Op"
      _ -> "en"
    end
  end
end
