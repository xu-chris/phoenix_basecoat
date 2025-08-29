defmodule MyAppWeb.Components do
  @moduledoc """
  Central orchestrator for MyApp's component system.

  Provides macro infrastructure for building and using UI components across the
  application. Each component is defined in its own module under
  `MyAppWeb.Components.*` and made available through this central import system.

  ## Usage

  **In LiveViews and Controllers:**
  ```elixir
  defmodule MyAppWeb.SomeLive do
    use MyAppWeb, :live_view
    # Components automatically available via html_helpers
  end
  ```

  **Component Development:**
  ```elixir
  defmodule MyAppWeb.Components.NewComponent do
    use MyAppWeb.Components, :component
    # Auto-includes Phoenix.Component, Gettext, helpers, JS
  end
  ```

  **In Templates:**
  ```heex
  <.button variant="primary">Click me</.button>
  <.modal id="example">Content</.modal>
  ```

  ## Adding New Components

  1. Create module in `lib/myapp_web/components/my_component.ex`
  2. Add `import MyAppWeb.Components.MyComponent` to `__using__/1` macro
  3. Component automatically available in all LiveViews and templates

  **Built with:** Tailwind CSS, Heroicons, Phoenix.Component
  """

  @doc """
  Base macro for component development.

  Provides Phoenix.Component, Gettext, animation helpers, and LiveView.JS.
  Used via `use MyAppWeb.Components, :component` in component modules.
  """
  def component do
    quote do
      use Phoenix.Component
      use Gettext, backend: MyAppWeb.Gettext

      import MyAppWeb.Components.Helpers

      alias Phoenix.LiveView.JS
    end
  end

  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end

  defmacro __using__(_) do
    quote do
      import MyAppWeb.Components.Avatar
      import MyAppWeb.Components.Badge
      import MyAppWeb.Components.Button
      import MyAppWeb.Components.Popover
      import MyAppWeb.Components.Separator
      import MyAppWeb.Components.Sidebar
      import MyAppWeb.Components.Table
      import MyAppWeb.Components.Tooltip
    end
  end
end
