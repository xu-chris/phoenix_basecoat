defmodule MyAppWeb.Components.Avatar do
  @moduledoc """
  Avatar components for displaying user profile images and initials.

  Avatars are visual representations of users or entities, providing a human
  touch to interfaces and helping users quickly identify content ownership,
  authorship, or association.

  ## Design Principles

  **Recognition**: Avatars use profile images when available, falling back to
  initials to maintain consistent visual identity and user recognition.

  **Consistency**: All avatar variants follow uniform sizing, shape, and spacing
  patterns to create cohesive user experiences across the interface.

  **Accessibility**: Avatars include proper alt text, support keyboard navigation
  when interactive, and work effectively across different screen sizes.

  ## Accessibility

  - Uses semantic HTML with descriptive alt text for images
  - Supports keyboard focus for interactive avatars (within links/buttons)
  - Maintains sufficient color contrast for initials
  - Provides meaningful usernames for screen readers
  - Works across different display densities and zoom levels

  ## Components

  This module provides two main components:

  - `avatar/1` - Individual avatar with image or initials fallback
  - `avatar_group/1` - Collection of overlapping avatars for teams or groups
  """
  use MyAppWeb.Components, :component

  import MyAppWeb.Components.Tooltip

  attr(:username, :string,
    required: true,
    doc: "user's name for alt text and initials generation"
  )

  attr(:size, :integer,
    default: 8,
    doc: "avatar size using Tailwind's size-* classes (e.g., 8 = 2rem)"
  )

  attr(:class, :string, doc: "additional CSS classes for customization")
  attr(:src, :string, default: nil, doc: "profile image URL; falls back to initials if nil")

  attr(:with_tooltip, :boolean,
    default: false,
    doc: "whether to wrap avatar in a tooltip showing the username"
  )

  @doc """
  Renders an avatar with profile image or initials fallback.

  Displays a user's profile image when available, automatically falling back to
  generated initials when no image is provided. Supports tooltips, custom sizing,
  and flexible styling options.

  ## Usage Guidelines

  **Use avatars to:**
  - Represent users in interfaces and content
  - Show authorship or ownership of content
  - Provide visual identity in user lists or comments
  - Create personal connection points in the interface
  - Indicate user presence or activity

  **Avoid using avatars for:**
  - Non-user entities (use icons instead)
  - Decorative purposes without user association
  - Critical functionality that requires text labels
  - Contexts where user privacy is paramount

  ## Examples

      <!-- Basic avatar with image -->
      <.avatar username="John Doe" src="https://example.com/john.jpg" />

      <!-- Initials fallback -->
      <.avatar username="Jane Smith" />

      <!-- Different sizes -->
      <.avatar username="Bob Wilson" size={12} src="/images/bob.jpg" />

      <!-- With tooltip -->
      <.avatar username="Alice Cooper" with_tooltip />

      <!-- Custom styling -->
      <.avatar username="David Lee" class="ring-2 ring-primary" />

      <!-- Interactive avatar in button -->
      <button class="focus:ring-2 focus:ring-primary rounded-full">
        <.avatar username="Sarah Jones" src="/avatars/sarah.jpg" />
      </button>

  ## Implementation Notes

  The component automatically generates initials from the username by taking the
  first letter of the first word and the first letter of the last word (when
  multiple words exist). Images are displayed with proper alt text for
  accessibility. The tooltip variant wraps the avatar in a tooltip component.
  """

  def avatar(%{with_tooltip: true} = assigns) do
    ~H"""
    <.tooltip text={@username}>
      <.avatar
        username={@username}
        size={@size}
        class={assigns[:class]}
        src={@src}
        with_tooltip={false}
      />
    </.tooltip>
    """
  end

  def avatar(%{src: nil} = assigns) do
    assigns = assign(assigns, :initials, initials_from_name(assigns[:username]))

    ~H"""
    <span class={"size-#{@size} select-none shrink-0 bg-muted flex items-center justify-center rounded-full #{assigns[:class]}"}>
      {@initials}
    </span>
    """
  end

  def avatar(assigns) do
    ~H"""
    <img
      class={"size-#{@size} select-none shrink-0 object-cover rounded-full #{assigns[:class]}"}
      alt={"#{@username}"}
      src={"#{@src}"}
    />
    """
  end

  attr(:class, :string, doc: "additional CSS classes for group container customization")
  attr(:size, :integer, default: 8, doc: "uniform size for all avatars in the group")
  slot(:inner_block, required: true, doc: "avatar components to display in overlapping formation")

  @doc """
  Renders a group of overlapping avatars for teams or collections.

  Displays multiple avatars in an overlapping layout, commonly used to show
  teams, collaborators, or multiple users associated with content. Automatically
  applies consistent sizing and border styling to create visual cohesion.

  ## Usage Guidelines

  **Use avatar groups to:**
  - Show team members or collaborators
  - Display multiple content contributors
  - Represent shared ownership or participation
  - Create compact user representations in lists
  - Indicate group activities or assignments

  **Design considerations:**
  - Limit to 3-5 avatars for optimal readability
  - Consider "+N more" indicators for larger groups
  - Ensure adequate touch targets for interactive groups
  - Maintain consistent ordering (e.g., by activity, alphabetical)

  ## Examples

      <!-- Basic avatar group -->
      <.avatar_group>
        <.avatar username="Alice" src="/avatars/alice.jpg" />
        <.avatar username="Bob" src="/avatars/bob.jpg" />
        <.avatar username="Charlie" />
      </.avatar_group>

      <!-- Custom size and styling -->
      <.avatar_group size={12} class="[&_img]:grayscale hover:space-x-1">
        <.avatar username="Team Lead" src="/avatars/lead.jpg" />
        <.avatar username="Developer" src="/avatars/dev.jpg" />
        <.avatar username="Designer" src="/avatars/design.jpg" />
      </.avatar_group>

      <!-- With tooltips and hover effects -->
      <.avatar_group class="[&_*]:transition-all [&_*]:ease-in-out [&_*]:duration-300">
        <.avatar username="John Smith" with_tooltip class="hover:grayscale-0" />
        <.avatar username="Jane Doe" with_tooltip class="hover:grayscale-0" />
      </.avatar_group>

  ## Implementation Notes

  The group container applies negative margin spacing to create overlap and adds
  consistent border styling to individual avatars. The component supports custom
  sizing that propagates to all child avatars through CSS classes.
  """

  def avatar_group(assigns) do
    ~H"""
    <div class={"flex -space-x-2 [&_img]:ring-background [&_img]:ring-2 [&_img]:size-#{@size} [&_img]:shrink-0 [&_img]:object-cover [&_img]:rounded-full #{assigns[:class]}"}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  defp initials_from_name(nil), do: ""
  defp initials_from_name(""), do: ""

  defp initials_from_name(name) when is_binary(name) do
    name
    |> String.split()
    |> take_first_and_last_if_needed()
    |> Enum.map_join(fn word -> word |> String.first() |> String.capitalize() end)
  end

  # Takes at most two strings from a list: if more than two, returns [first, last], else returns as-is
  defp take_first_and_last_if_needed(list) when is_list(list) do
    case list do
      [first | rest] when length(rest) > 1 -> [first, List.last(rest)]
      _ -> list
    end
  end
end
