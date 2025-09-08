defmodule MyAppWeb.Components.Popover do
  @moduledoc """
  Popover components for displaying contextual content above other interface elements.

  Popovers show temporary views that appear above other content when triggered,
  containing related functionality or information that supports the main interface
  without permanently taking up screen space.

  ## Accessibility

  Popovers include proper ARIA attributes, keyboard navigation, and focus management.
  They automatically close when clicking outside or pressing Escape.
  """
  use MyAppWeb.Components, :component

  attr(:id, :string, default: nil, doc: "unique identifier (auto-generated if not provided)")

  attr(:role, :string,
    values: ~w(menu listbox tree grid dialog),
    doc: "ARIA role that determines the popover's semantic meaning and keyboard behavior"
  )

  attr(:type, :string,
    values: ~w(popover select dropdown-list dropdown-menu),
    default: "popover",
    doc: "popover type that determines styling and interaction patterns"
  )

  attr(:class, :string, default: "", doc: "additional CSS classes for customization")
  attr(:rest, :global, doc: "additional HTML attributes")

  attr(:close_on_click, :boolean,
    default: true,
    doc: "whether popover closes when clicking outside (disable for multi-select)"
  )

  slot :trigger, required: true do
    attr(:class, :string, required: true, doc: "CSS classes for the trigger button")
  end

  slot :content, required: true do
    attr(:class, :string, required: false, doc: "CSS classes for the popover content container")
  end

  slot(:inner_block, doc: "additional content rendered outside the popover structure")

  @doc """
  Renders a popover with trigger button and contextual content.

  Creates an accessible popover that appears above other content when triggered.
  Supports different types for various use cases like menus, selects, and general popovers.

  ## Examples

      <!-- Basic popover -->
      <.popover>
        <:trigger class="btn-outline">Settings</:trigger>
        <:content>
          <div class="p-4">Popover content</div>
        </:content>
      </.popover>

      <!-- Dropdown menu -->
      <.popover role="menu" type="dropdown-menu">
        <:trigger class="btn-outline">Actions</:trigger>
        <:content>
          <div role="menuitem">Edit</div>
          <div role="menuitem">Delete</div>
        </:content>
      </.popover>

      <!-- Select popover -->
      <.popover role="listbox" type="select" close_on_click={false}>
        <:trigger class="btn-outline">Choose option</:trigger>
        <:content>
          <div role="option" data-value="1">Option 1</div>
          <div role="option" data-value="2">Option 2</div>
        </:content>
      </.popover>
  """

  def popover(%{id: nil} = assigns) do
    assigns
    |> assign(id: generate_component_id("popover"))
    |> popover()
  end

  def popover(assigns) do
    ~H"""
    <div
      id={"#{@id}"}
      data-id={"#{@id}"}
      data-type={@type}
      class={"#{@type} #{@class}"}
      {@rest}
      phx-hook=".Popover"
    >
      <button
        :for={content <- @trigger}
        type="button"
        class={"aria-expanded:outline-solid outline-accent #{content[:class] || "btn-outline"}"}
        id={"#{@id}-trigger"}
        aria-expanded="false"
        aria-controls={"#{@id}-popover"}
        phx-click={show_popover(%JS{}, @id)}
        aria-haspopup={assigns[:role]}
        phx-key="escape"
        phx-window-keydown={hide_popover(%JS{}, @id)}
        phx-click-away={@close_on_click && hide_popover(%JS{}, @id)}
      >
        {render_slot(content)}
      </button>

      <div
        :for={content <- @content}
        id={"#{@id}-popover"}
        data-popover
        aria-orientation="vertical"
        dir="ltr"
        data-orientation="vertical"
        tabindex="-1"
        data-state="closed"
        aria-hidden="true"
        class={"w-80 #{content[:class]}"}
        role={assigns[:role]}
        aria-labelledby={"#{@id}-trigger"}
        phx-click-away={hide_popover(%JS{}, @id)}
      >
        {render_slot(content)}
      </div>
      {render_slot(@inner_block)}
    </div>

    <script :type={Phoenix.LiveView.ColocatedHook} name=".Popover">
      export default {
        mounted() {
          this.setup()
        },

        updated() {
          this.setup()
        },

        setup() {
          const el = this.el;
          const type = el.dataset.type;
          const trigger = el.querySelector(':scope > button');
          const popover = el.querySelector(':scope > [data-popover]');

          // Get elements based on type
          const isSelect = ['select', 'dropdown-list'].includes(type);
          const isMenu = type === 'dropdown-menu';

          const contentElement = popover;

          let items = Array.from(el.querySelectorAll('[role^="menuitem"],[role="option"]'));

          // Filter out disabled items for menus
          items = items.filter(item =>
            !item.hasAttribute('disabled') &&
            item.getAttribute('aria-disabled') !== 'true'
          );

          const selectedLabel = trigger.querySelector(':scope > span');
          const input = el.querySelector(':scope > input[type="hidden"]');
          const filter = el.querySelector('header input[type="text"]');

          let visibleItems = [...items];
          let activeIndex = -1;

          // Set active item and manage ARIA attributes
          const setActiveItem = (index) => {
            if (activeIndex > -1 && items[activeIndex]) {
              items[activeIndex].classList.remove('active');
            }

            activeIndex = index;

            if (activeIndex > -1) {
              const activeItem = items[activeIndex];
              activeItem.classList.add('active').focus();
              if (activeItem.id) {
                trigger.setAttribute('aria-activedescendant', activeItem.id);
              } else {
                trigger.removeAttribute('aria-activedescendant');
              }
            } else {
              trigger.removeAttribute('aria-activedescendant');
            }
          };

          // Update selected value and trigger change event (select only)
          const updateValue = (item, triggerEvent = true) => {
            if (!isSelect || !item) return;

            if (selectedLabel) {
              selectedLabel.innerHTML = item.dataset.label || item.innerHTML;
            }
            if (input) {
              input.value = item.dataset.value;
            }
            contentElement.querySelector('[role="option"][aria-selected="true"]')?.removeAttribute('aria-selected');
            item.setAttribute('aria-selected', 'true');

            if (triggerEvent) {
              const event = new CustomEvent('change', {
                detail: { value: item.dataset.value },
                bubbles: true
              });
              el.dispatchEvent(event);
            }
          };

          // Handle item selection/activation
          const activateItem = (item) => {
            if (!item) return;

            if (isSelect) {
              const oldValue = input?.value;
              const newValue = item.dataset.value;

              if (newValue != null && newValue !== oldValue) {
                updateValue(item);
              }
            } else if (isMenu) {
              // For menus, just trigger the click
              item.click();
            }

            // Close popover after selection
            trigger.click();
          };

          // Filter functionality
          if (filter) {
            const filterOptions = () => {
              const searchTerm = filter.value.trim().toLowerCase();

              visibleItems = [];
              items.forEach(item => {
                const itemText = (item.dataset.label || item.textContent).trim().toLowerCase();
                const matches = itemText.includes(searchTerm);
                item.setAttribute('aria-hidden', String(!matches));
                if (matches) {
                  visibleItems.push(item);
                }
              });
            };

            filter.addEventListener('input', filterOptions);
          }

          // Initialize with current value
          if (input) {
            let initialItem = items.find(item => item.dataset.value === input.value);
            if (!initialItem) {
              initialItem = items.find(item => item.dataset.value !== undefined) ?? items[0];
            }
            if (initialItem) {
              updateValue(initialItem, false);
            }
          }

          // Keyboard navigation
          const handleKeyNavigation = (event) => {
            const isPopoverOpen = popover.getAttribute('aria-hidden') === 'false';
            const navigationKeys = ['ArrowDown', 'ArrowUp', 'Enter', 'Home', 'End', 'Escape'];

            if (isMenu) {
              navigationKeys.push(' '); // Space for menu items
            }

            if (!navigationKeys.includes(event.key)) {
              return;
            }

            if (!isPopoverOpen) {
              if (event.key === 'Escape') return;

              if (['Enter', ' '].includes(event.key) ||
                  (event.key === 'ArrowDown' && isMenu) ||
                  (event.key === 'ArrowUp' && isMenu)) {
                event.preventDefault();
                trigger.click();

                // Set initial focus for menu
                if (isMenu) {
                  setTimeout(() => {
                    const availableItems = items.filter(item =>
                      !item.hasAttribute('disabled') &&
                      item.getAttribute('aria-disabled') !== 'true'
                    );
                    if (availableItems.length > 0) {
                      const targetIndex = event.key === 'ArrowUp' ? availableItems.length - 1 : 0;
                      const targetItem = availableItems[targetIndex];
                      setActiveItem(items.indexOf(targetItem));
                    }
                  }, 0);
                }
              }
              return;
            }

            event.preventDefault();

            if (event.key === 'Escape') {
              trigger.click();
              return;
            }

            if (['Enter', ' '].includes(event.key)) {
              if (activeIndex > -1) {
                activateItem(items[activeIndex]);
              }
              return;
            }

            if (visibleItems.length === 0) return;

            const currentVisibleIndex = activeIndex > -1 ? visibleItems.indexOf(items[activeIndex]) : -1;
            let nextVisibleIndex = currentVisibleIndex;

            switch (event.key) {
              case 'ArrowDown':
                if (isMenu) {
                  const currentIndex = visibleItems.indexOf(items[activeIndex]);
                  nextVisibleIndex = currentIndex === -1 ? 0 : Math.min(currentIndex + 1, visibleItems.length - 1);
                } else {
                  if (currentVisibleIndex < visibleItems.length - 1) {
                    nextVisibleIndex = currentVisibleIndex + 1;
                  }
                }
                break;
              case 'ArrowUp':
                if (isMenu) {
                  const currentIndex = visibleItems.indexOf(items[activeIndex]);
                  nextVisibleIndex = currentIndex === -1 ? visibleItems.length - 1 : Math.max(currentIndex - 1, 0);
                } else {
                  if (currentVisibleIndex > 0) {
                    nextVisibleIndex = currentVisibleIndex - 1;
                  } else if (currentVisibleIndex === -1) {
                    nextVisibleIndex = 0;
                  }
                }
                break;
              case 'Home':
                nextVisibleIndex = 0;
                break;
              case 'End':
                nextVisibleIndex = visibleItems.length - 1;
                break;
            }

            if (nextVisibleIndex !== currentVisibleIndex && nextVisibleIndex >= 0 && nextVisibleIndex < visibleItems.length) {
              const newActiveItem = visibleItems[nextVisibleIndex];
              const newIndex = items.indexOf(newActiveItem);
              setActiveItem(newIndex);
              newActiveItem.scrollIntoView({ block: 'nearest', behavior: 'smooth' });
            }
          };

          // Event listeners
          el.addEventListener('keydown', handleKeyNavigation);

          // Mouse interaction
          contentElement.addEventListener('mousemove', (event) => {
            const item = event.target.closest(isMenu ? '[role^="menuitem"]' : '[role="option"]');
            if (item && visibleItems.includes(item)) {
              const index = items.indexOf(item);
              if (index !== activeIndex) {
                setActiveItem(index);
              }
            }
          });

          contentElement.addEventListener('mouseleave', () => {
            if (isSelect) {
              const selectedItem = contentElement.querySelector('[role="option"][aria-selected="true"]');
              if (selectedItem) {
                setActiveItem(items.indexOf(selectedItem));
              } else {
                setActiveItem(-1);
              }
            } else {
              setActiveItem(-1);
            }
          });

          // Click to activate item
          contentElement.addEventListener('click', (event) => {
            const clickedItem = event.target.closest(isMenu ? '[role^="menuitem"]' : '[role="option"]');
            if (clickedItem) {
              activateItem(clickedItem);
            }
          });

          // Set initial active item when popover opens (select only)
          if (isSelect) {
            el.addEventListener('phx:show-popover', () => {
              const selectedItem = contentElement.querySelector('[role="option"][aria-selected="true"]');
              if (selectedItem) {
                setActiveItem(items.indexOf(selectedItem));
                selectedItem.scrollIntoView({ block: 'nearest' });
              }
            });
          }
        }
      }
    </script>
    """
  end

  def hide_popover(js \\ %JS{}, id) do
    js
    |> JS.set_attribute({"aria-expanded", "false"})
    |> JS.set_attribute({"aria-hidden", "true"}, to: "##{id}-popover")
    |> JS.set_attribute({"value", ""}, to: "##{id}-popover header input[type='search']")
    |> JS.set_attribute({"data-state", "closed"}, to: "##{id}-popover")
    |> JS.pop_focus()
  end

  def show_popover(js \\ %JS{}, id) do
    js
    |> JS.push_focus()
    |> JS.set_attribute({"aria-expanded", "true"})
    |> JS.set_attribute({"aria-hidden", "false"}, to: "##{id}-popover")
    |> JS.set_attribute({"data-state", "open"}, to: "##{id}-popover")
    |> JS.focus_first(to: "##{id}-popover")
  end
end
