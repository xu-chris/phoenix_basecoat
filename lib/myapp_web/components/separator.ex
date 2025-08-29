defmodule MyAppWeb.Components.Separator do
  @moduledoc """
  Separator component for creating visual divisions between content sections.

  Provides horizontal divider lines with optional text labels to separate
  content sections, form groups, or menu items. Supports both plain dividers
  and labeled dividers for enhanced content organization.

  ## Accessibility

  - Uses proper ARIA `separator` role for screen reader support
  - Non-focusable implementation follows static separator pattern
  - Label text provides additional context when present
  - Maintains sufficient color contrast (gray-300 borders meet WCAG standards)

  ## Examples

      <.separator />
      <.separator label="Or continue with" />
      <.separator label="Settings" class="my-8" />
  """
  use MyAppWeb.Components, :component

  attr(:label, :string, default: nil, doc: "optional text label displayed in the center")
  attr(:class, :string, default: "", doc: "additional CSS classes")

  def separator(%{label: nil} = assigns) do
    ~H"""
    <div class={"flex items-center my-4 #{@class}"} role="separator" aria-hidden="true">
      <div class="grow border-t border-gray-300"></div>
    </div>
    """
  end

  def separator(assigns) do
    ~H"""
    <div class={"flex items-center my-4 #{@class}"} role="separator" aria-label={@label}>
      <div class="grow border-t border-gray-300"></div>
      <span class="px-2 text-xs text-gray-500 font-medium">{@label}</span>
      <div class="grow border-t border-gray-300"></div>
    </div>
    """
  end
end
