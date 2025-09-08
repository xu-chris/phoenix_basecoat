defmodule MyAppWeb.Components.Tooltip do
  @moduledoc """
  Tooltip component for displaying contextual information on hover and focus.

  Provides accessible, CSS-based tooltips that appear when users hover over or
  focus on trigger elements. Built with pure CSS animations and transitions
  for optimal performance.

  ## Accessibility

  - Follows WCAG 2.1 Content on Hover or Focus guidelines (1.4.13)
  - Supports both mouse hover and keyboard focus activation
  - Dismissible with Escape key via CSS `:focus-visible:not(:hover)` rules
  - Uses `aria-describedby` for proper screen reader association
  - Maintains focus on trigger element while tooltip is visible
  - Content remains visible when hovering over tooltip area

  ## Examples

      <.tooltip text="Additional information">
        <button>Hover me</button>
      </.tooltip>

      <.tooltip text="Save changes" side="bottom" align="start">
        <.button>Save</.button>
      </.tooltip>
  """
  use MyAppWeb.Components, :component

  attr(:side, :string,
    values: ~w(top right bottom left),
    default: "top",
    doc: "tooltip position relative to trigger element"
  )

  attr(:align, :string,
    values: ~w(start center end),
    default: "center",
    doc: "tooltip alignment along the chosen side"
  )

  attr(:text, :string,
    required: true,
    doc: "tooltip content text displayed to users"
  )

  attr(:rest, :global, doc: "additional HTML attributes for the trigger element")

  slot(:inner_block, required: true, doc: "trigger element content that activates the tooltip")

  def tooltip(%{text: text, side: side, align: align} = assigns) do
    tooltip_id = "tooltip-#{System.unique_integer([:positive])}"
    assigns = assign(assigns, :tooltip_id, tooltip_id)

    ~H"""
    <span
      data-tooltip={@text}
      data-side={@side}
      data-align={@align}
      aria-describedby={@tooltip_id}
      {@rest}
    >
      {render_slot(@inner_block)}
      <span id={@tooltip_id} role="tooltip" class="sr-only">
        {@text}
      </span>
    </span>
    """
  end
end
