defmodule MyAppWeb.Components.Icon do
  @moduledoc """
  Icon components for displaying vector icons throughout the interface.

  Icons provide visual cues and enhance usability by representing actions,
  objects, or concepts in a compact, recognizable format.

  ## Accessibility

  Icons are marked as decorative (`aria-hidden="true"`) by default and should
  be accompanied by text labels for critical actions or meaningful content.
  """
  use MyAppWeb.Components, :component

  @doc """
  Renders a Heroicon with configurable styling and accessibility features.

  Icons use the `hero-` prefix and support three styles via suffixes:
  outline (default), `-solid`, and `-mini`.

  ## Examples

      <.icon name="hero-x-mark" />
      <.icon name="hero-heart-solid" class="size-5 text-red-500" />
      <.icon name="hero-arrow-path" class="animate-spin" />
  """
  attr(:name, :string,
    required: true,
    doc: "Heroicon name with 'hero-' prefix (e.g., 'hero-x-mark', 'hero-arrow-path')"
  )

  attr(:class, :string,
    default: "size-4",
    doc: "CSS classes for styling, sizing, and positioning (default: 'size-4' for 16px)"
  )

  attr(:rest, :global,
    include: ~w(aria-hidden data-slot),
    doc: "additional HTML attributes including ARIA attributes for accessibility"
  )

  def icon(%{name: "hero-" <> _} = assigns) do
    ~H"""
    <span role="img" aria-hidden="true" class={"#{@name} #{@class}"} {@rest} />
    """
  end
end
