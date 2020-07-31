# Aseprite Plugins

Plugins for Aseprite

- Sand: To create random pixels with a palette and decreasing options.
- Circular Gradient: To create elliptical gradients, with palette, translation, scaling, and spatter!

## Introduction

Now I can create custom tasks in Aseprite with plugins, I want to create some features that were available in other software like DPaint that was the one used to create many adventure games.

## Circular Gradients 1.0

![Circular gradients](https://github.com/juanpaexpedite/AsepritePlugins/blob/master/Circles/CircularGradients.png)

The gradient is always created in a new layer and works with and without a selection area.

- Position and initial size
- Colors for the gradient steps
- Increasing step properties
- Spatter!

## SAND 1.1

![Sand dialog](https://github.com/juanpaexpedite/AsepritePlugins/blob/master/Sand/SandScreenshot_1_1.png)

### Release notes 1.1

Now it includes the option of the start decreasing percentage:

![Sand dialog](https://github.com/juanpaexpedite/AsepritePlugins/blob/master/Sand/SandDecreasingExample.png)

### Release notes 1.0

This script is used to fill a selection within an image in RGB mode with the colors added, it has two modes

- Decreasing (by default) it makes passes as colors in the list decreasing the chance of appearance.
- Not decreasing, it makes just equally weighted random selection from the colors in the list.
- Divide instead substract the probability of appearance of a color in each decreasing step.

![Sand dialog](https://github.com/juanpaexpedite/AsepritePlugins/blob/master/Sand/SandComparision2.png)
