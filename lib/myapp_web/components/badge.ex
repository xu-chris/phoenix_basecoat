defmodule MyAppWeb.Components.Badge do
  @moduledoc """
  Badge components for displaying status, categories, and metadata.

  Badges are compact, read-only elements that communicate status, categorize content,
  or provide supplementary information. They appear as small, rounded containers
  with text or icons that help users quickly identify and understand content.

  ## Design Principles

  **Clarity**: Badges use clear, concise text and appropriate colors to communicate
  their purpose without ambiguity.

  **Consistency**: All badge variants follow consistent visual patterns for size,
  spacing, and typography to maintain interface coherence.

  **Hierarchy**: Different badge types (primary, secondary, destructive, outline)
  establish clear information hierarchy through color and visual weight.

  ## Accessibility

  - Uses semantic HTML with proper color contrast ratios
  - Supports focus states for interactive badges (links)
  - Text content is readable by screen readers
  - Color is not the only means of conveying information

  ## CSS Classes

  When using as direct HTML elements (not the component), use these classes:
  - `.badge` or `.badge-primary` - Primary/default styling
  - `.badge-secondary` - Secondary styling
  - `.badge-destructive` - Destructive/error styling
  - `.badge-outline` - Outline styling
  """
  use MyAppWeb.Components, :component

  attr(:type, :string,
    values: ~w(default primary secondary destructive outline),
    default: "default",
    doc: "badge variant that determines the visual styling and semantic meaning"
  )

  attr(:class, :string, doc: "additional CSS classes for customization")

  slot(:inner_block, required: true, doc: "content slot for text, icons, or other elements")

  @doc """
  Renders a badge with configurable styling and content.

  Badges communicate status, categorize content, or provide supplementary information
  in a compact, visually distinct format.

  ## Usage Guidelines

  **Use badges to:**
  - Indicate status (active, pending, completed)
  - Categorize content (tags, labels, types)
  - Display counts or numerical indicators
  - Show metadata that supplements primary content
  - Create interactive links with visual distinction

  **Avoid using badges for:**
  - Primary actions (use buttons instead)
  - Long text content (keep labels concise)
  - Critical alerts (use alert components)
  - Complex interactive elements

  ## Variants

  - `default/primary`: High contrast, for important status or primary categories
  - `secondary`: Medium contrast, for supplementary information
  - `destructive`: Red styling, for errors, warnings, or negative states
  - `outline`: Subtle styling, for less prominent categorization

  ## Examples

      <!-- Basic badges -->
      <.badge>New</.badge>
      <.badge type="secondary">Draft</.badge>
      <.badge type="destructive">Error</.badge>
      <.badge type="outline">Optional</.badge>

      <!-- With icons -->
      <.badge type="outline">
        <.icon name="hero-check" />
        Verified
      </.badge>

      <!-- As links -->
      <a href="/category" class="badge-primary">
        Category
        <.icon name="hero-arrow-right" />
      </a>

      <!-- Notification badges -->
      <.badge class="rounded-full min-w-5 px-1 font-mono tabular-nums">99+</.badge>

  ## Implementation Notes

  The component renders a `<span>` element with appropriate CSS classes.
  For interactive badges, wrap the component in an anchor tag or button
  and apply the corresponding CSS class directly to the wrapper element.
  """
  def badge(assigns) do
    ~H"""
    <span class={"#{badge_class(@type)} #{assigns[:class]}"}>{render_slot(@inner_block)}</span>
    """
  end

  defp badge_class(type) do
    case type do
      "default" -> "badge"
      "primary" -> "badge-primary"
      "secondary" -> "badge-secondary"
      "destructive" -> "badge-destructive"
      "outline" -> "badge-outline"
    end
  end
end
