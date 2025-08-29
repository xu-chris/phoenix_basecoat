defmodule MyAppWeb.Components.Button do
  @moduledoc """
  Button components for actions, navigation, and user interactions.

  Buttons enable users to take actions, make choices, and navigate through
  interfaces. They communicate what action will occur when the user touches
  or clicks them, providing clear affordances for user interaction.

  ## Design Principles

  **Clarity**: Button labels and visual styling clearly communicate the action
  that will be performed, using appropriate visual hierarchy and color meaning.

  **Consistency**: All button variants follow uniform interaction patterns,
  sizing, and spacing to create predictable user experiences.

  **Accessibility**: Buttons support keyboard navigation, screen readers, focus
  indicators, and appropriate semantic markup for universal access.

  ## Accessibility

  - Uses semantic HTML with proper button and link elements
  - Supports keyboard navigation (Enter/Space for activation)
  - Provides clear focus indicators and hover states
  - Includes loading states with appropriate disabled behavior
  - Works with screen readers and assistive technologies
  - Maintains adequate color contrast ratios

  ## CSS Classes

  When using direct HTML elements, use these button classes:
  - `.btn` or `.btn-primary` - Primary action styling
  - `.btn-secondary` - Secondary action styling
  - `.btn-outline` - Outline button styling
  - `.btn-ghost` - Ghost/minimal styling
  - `.btn-destructive` - Destructive action styling
  - `.btn-link` - Link-style button
  - Size modifiers: `.btn-sm`, `.btn-lg`
  - Icon-only variants: `.btn-icon`, `.btn-sm-icon`, `.btn-lg-icon`
  """
  use MyAppWeb.Components, :component

  attr(:rest, :global,
    include: ~w(href navigate patch method),
    doc: "global HTML attributes including navigation attributes"
  )

  attr(:variant, :string,
    values: ["primary", "secondary", "outline", "ghost", "destructive", "link", nil],
    default: nil,
    doc: "button variant that determines visual styling and semantic meaning"
  )

  attr(:size, :string,
    values: ["sm", "md", "lg", nil],
    default: nil,
    doc: "button size variant (nil defaults to medium)"
  )

  attr(:class, :string,
    default: "",
    doc: "additional CSS classes for customization"
  )

  attr(:icon_only, :boolean,
    default: false,
    doc: "whether button contains only an icon (applies square aspect ratio)"
  )

  attr(:loading, :boolean,
    default: false,
    doc: "shows loading spinner and disables interaction"
  )

  attr(:disabled, :boolean,
    default: false,
    doc: "disables button interaction and applies disabled styling"
  )

  slot(:inner_block,
    required: true,
    doc: "button content including text, icons, and other elements"
  )

  @doc """
  Renders a button with configurable styling, states, and navigation support.

  Automatically chooses between `<button>` and `<.link>` elements based on
  navigation attributes, supporting both form actions and routing while
  maintaining consistent visual styling and interaction patterns.

  ## Usage Guidelines

  **Use buttons for:**
  - Primary and secondary actions (submit, save, cancel)
  - Triggering immediate actions or state changes
  - Opening dialogs, drawers, or modals
  - Navigation when styled as call-to-action elements
  - Form submissions and data operations

  **Avoid using buttons for:**
  - Purely decorative elements (use spans or divs)
  - Navigation that should use standard link semantics
  - Actions that are better represented as toggles or switches
  - Contexts where text links would be more appropriate

  ## Variants

  - `primary` (default): High contrast, for primary actions
  - `secondary`: Medium contrast, for secondary actions
  - `outline`: Bordered style, for alternative actions
  - `ghost`: Minimal style, for subtle actions
  - `destructive`: Red styling, for dangerous or irreversible actions
  - `link`: Text-style, for actions that behave like links

  ## Examples

      <!-- Basic actions -->
      <.button>Save</.button>
      <.button variant="primary">Submit</.button>
      <.button variant="secondary">Cancel</.button>
      <.button variant="destructive">Delete</.button>

      <!-- With icons -->
      <.button variant="outline">
        <.icon name="hero-paper-airplane" />
        Send Message
      </.button>

      <!-- Navigation buttons -->
      <.button navigate={~p"/dashboard"} variant="primary">
        Go to Dashboard
      </.button>

      <!-- Different sizes -->
      <.button size="sm">Small Button</.button>
      <.button size="lg">Large Button</.button>

      <!-- Icon-only buttons -->
      <.button variant="ghost" icon_only>
        <.icon name="hero-ellipsis-horizontal" />
      </.button>

      <!-- Loading and disabled states -->
      <.button loading>Processing...</.button>
      <.button disabled>Unavailable</.button>

      <!-- Form actions -->
      <.button type="submit" variant="primary">Submit Form</.button>
      <.button type="button" phx-click="cancel">Cancel</.button>

  ## Implementation Notes

  The component automatically renders as a `<.link>` when navigation attributes
  (href, navigate, patch) are present, otherwise renders as a `<button>`.
  Loading state shows a spinner icon and disables interaction. Icon-only buttons
  apply square aspect ratio styling for consistent appearance.
  """

  def button(%{rest: rest} = assigns) do
    size_class = (assigns.size && "-" <> "#{assigns.size}") || ""
    icon_class = if assigns.icon_only == true, do: "-icon"

    variant_class =
      case assigns.variant do
        "primary" -> ""
        "secondary" -> "-secondary"
        "outline" -> "-outline"
        "ghost" -> "-ghost"
        "destructive" -> "-destructive"
        "link" -> "-link"
        _ -> "-secondary"
      end

    loading_class = if assigns.loading == true, do: " cursor-progress!"

    assembled_class =
      "btn#{size_class}#{icon_class}#{variant_class}#{loading_class} #{assigns[:class]}"

    assigns = assign(assigns, class: assembled_class)

    if rest[:href] || rest[:navigate] || rest[:patch] do
      ~H"""
      <.link class={@class} {@rest} disabled={@disabled || @loading}>
        <svg
          :if={@loading}
          xmlns="http://www.w3.org/2000/svg"
          width="24"
          height="24"
          viewBox="0 0 24 24"
          fill="none"
          stroke="currentColor"
          stroke-width="2"
          stroke-linecap="round"
          stroke-linejoin="round"
          class="animate-spin"
        >
          <path d="M12 2v4"></path>
          <path d="m16.2 7.8 2.9-2.9"></path>
          <path d="M18 12h4"></path>
          <path d="m16.2 16.2 2.9 2.9"></path>
          <path d="M12 18v4"></path>
          <path d="m4.9 19.1 2.9-2.9"></path>
          <path d="M2 12h4"></path>
          <path d="m4.9 4.9 2.9 2.9"></path>
        </svg>
        {render_slot(@inner_block)}
      </.link>
      """
    else
      ~H"""
      <button class={@class} {@rest} disabled={@disabled || @loading}>
        <svg
          :if={@loading}
          xmlns="http://www.w3.org/2000/svg"
          width="24"
          height="24"
          viewBox="0 0 24 24"
          fill="none"
          stroke="currentColor"
          stroke-width="2"
          stroke-linecap="round"
          stroke-linejoin="round"
          class="animate-spin"
        >
          <path d="M12 2v4"></path>
          <path d="m16.2 7.8 2.9-2.9"></path>
          <path d="M18 12h4"></path>
          <path d="m16.2 16.2 2.9 2.9"></path>
          <path d="M12 18v4"></path>
          <path d="m4.9 19.1 2.9-2.9"></path>
          <path d="M2 12h4"></path>
          <path d="m4.9 4.9 2.9 2.9"></path>
        </svg>
        {render_slot(@inner_block)}
      </button>
      """
    end
  end
end
