alias Chukinas.Geometry.{Position, Point, Rect}

defmodule Rect do
  @moduledoc"""
  A Rect is an in-grid rectangle, meaning it comprises only horizontal and vertical lines.
  """

  import Position.Guard

  use TypedStruct

  typedstruct enforce: true do
    field :start_position, Point.t()
    field :end_position, Point.t()
  end

  # *** *******************************
  # *** NEW

  def new(start_x, start_y, end_x, end_y) do
    %__MODULE__{
      start_position: Point.new(start_x, start_y),
      end_position: Point.new(end_x, end_y)
    }
  end
  def new(start_position, end_position) when has_position(start_position) and has_position(end_position) do
    %__MODULE__{
      start_position: start_position,
      end_position: end_position
    }
  end
  def new(width, height) when is_number(width) and is_number(height) do
    %__MODULE__{
      start_position: Point.origin(),
      end_position: Point.new(width, height)
    }
  end

  # *** *******************************
  # *** API

  def contains?(%__MODULE__{} = rect, position) when has_position(position) do
    Position.gte(position, rect.start_position) && Position.lte(position, rect.end_position)
  end

  def subtract(%__MODULE__{} = rect, position) when has_position(position) do
    new_rect = new(
      rect.start_position |> Position.subtract(position),
      rect.end_position |> Position.subtract(position)
    )
    new_rect
  end

  def apply_margin(%__MODULE__{} = rect, margin) when is_number(margin) do
    rect
    |> Map.update!(:start_position, &(Position.subtract(&1, margin)))
    |> Map.update!(:end_position, &(Position.add(&1, margin)))
  end

  def get_size(%__MODULE__{} = rect) do
    %{x: width, y: height} = Position.subtract(rect.end_position, rect.start_position)
    %{width: width, height: height}
  end

  def get_start_position(%__MODULE__{start_position: start_position}), do: start_position
  def get_end_position(%__MODULE__{end_position: end_position}), do: end_position

end
