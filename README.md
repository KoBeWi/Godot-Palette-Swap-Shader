# Godot Palette Swap Shader

This shader allows for remapping colors based on a provided palette. It's like your standard palette-swap, except it requires zero configuration, has virtually no limit for number of colors and supports animation.

## Basic usage

1. Get some image that you want to recolor.

![](https://github.com/KoBeWi/Godot-Palette-Swap-Shader/blob/master/ExampleProject/Orb.png)

2. Create a palette for this image. Top row of the palette are colors you want to replace, second row are the desired colors.

![](https://github.com/KoBeWi/Godot-Palette-Swap-Shader/blob/master/Media/ReadmeExamplePalette.png)

3. Assign shader to your Sprite or any other CanvasItem node.
4. Put the palette into the material params.
5. Voila!

![](https://github.com/KoBeWi/Godot-Palette-Swap-Shader/blob/master/Media/ReadmeUsage.gif)

## Animation

The shader has basic animation support. It will cycle through the rows of the assigned palette, based on the `fps` parameter. Let's consider this image:

![](https://github.com/KoBeWi/Godot-Palette-Swap-Shader/blob/master/ExampleProject/GrayscaleOrb.png)

And this palette:

![](https://github.com/KoBeWi/Godot-Palette-Swap-Shader/blob/master/Media/ReadmeExampleAnimation.png)

The first row are the grayscale reference colors from the image, the other rows are colors for animation. The result is this:

![](https://github.com/KoBeWi/Godot-Palette-Swap-Shader/blob/master/Media/ReadmeAnimation.gif?raw=true)

## Parameters

- `skip_first_row` - if disabled, the first row of palette will also be used for animation. In case of the above example, the orb would have one grayscale frame.
- `use_palette_alpha` - if enabled, the output color will also use the alpha value from the palette. Normally the alpha is ignored and uses the source alpha.
- `fps` - frames per second, or more like, rows per second in the animation.
- `palette` - the palette image.

## Palette format

The palette is divided in columns and rows.

![](https://github.com/KoBeWi/Godot-Palette-Swap-Shader/blob/master/Media/ReadmeHowToPalette.png)

The top row are "reference colors". The shader will replace these colors from the original with the other colors in subsequent rows. The colors in the same column are being cycled and the animation length depends on number of columns.

The shader supports any palette size (but Godot imports only up to 16k). Number of rows doesn't matter, but having too many columns will have impact on performance. It's fast enough to have tens of them, but hundreds/thousands might be problematic (I didn't test exact numbers, but I guess no one will use such big palette. Hopefully).

Note: Both palette and source image should be imported with `filter` option turned off.

## Palette generator

The asset comes bundled with `PaletteGenerator.gd` file. It's an editor script that will automatically generate a palette template for the selected node containing a texture. It checks every pixel for unique colors and puts them in a row, and adds a second empty row.

To use it:

1. Open `PaletteGenerator.gd` file in the script editor.
2. Select any node with a `texture` property (e.g. Sprite)
3. In the script editor, use File -> Run (Ctrl + Shift + X)
4. The palette appear in your files with the name `youroriginalimage_palette.png`

![](https://github.com/KoBeWi/Godot-Palette-Swap-Shader/blob/master/Media/ReadmeGeneratorUsage.gif)

## Technical details

The shader uses for loop to compare pixels. The colors are first converted to integer, so the comparison is faster and perfectly accurate. I optimized the code and there is only one `if` that will branch if your source image has colors that won't be replaced. The shader should be pretty fast, but I didn't test performance limits.
