> [!NOTE]
> This repo is in the process of creation.

# Phoenix Basecoat
Ready-to-copy UI components styled like the famous ShadCN/UI library and taken from [@hunvreus](https://github.com/hunvreus)'s awesome re-implementation in pure HTML and JS in [BasecoatUI](https://basecoatui.com).

## Philosophy
An component library is a core element of any application. They change according to corporate identity and user experience requirements. The components implemented in this repo don't resemble a hex package – they are ready to be copied directly into your project. They are ready to be changed and adapted by you. You copy them into your project and they will evolve on your end.

If you've learned something you want to share or have found some lacking functionality, please add a PR so you and others have the best possible components to start with.

## Requirements
The source code uses certain syntax that is not supported in older versions. The versions of specific packages are:

- Tailwind >= 4.0 (syntax of css classes)
- Phoenix LiveView >= 1.1 (because of colocated hooks and JS)

Make sure your project uses these versions before adopting the provided components.

## Getting started

### 1. Copy everything into your project
Make sure `basecoat.css` is either in your `assets/css/` folder or you copy the content into your `app.css`.

If you have decided for the first option, you need to import it into your `app.css` like this:

```diff
   @import "tailwindcss" source(none);
+  @import "./basecoat.css";
```

The rest goes into your `lib/myapp_web/components` directory.

If you want to replace your `core_components.ex` file, delete it.
In your `my_app_web.ex`, you have to replace `CoreComponents` with `Components`:

```diff
-  use MyApp.CoreComponents
+  use MyApp.Components
```

### 2. Use the components
Most components were kept very close to the `CoreComponents` to keep the migration small.
