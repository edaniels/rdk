package classification

import (
	"fmt"
	"image"
	"image/color"

	"github.com/fogleman/gg"

	"go.viam.com/rdk/rimage"
)

// Overlay returns a color image with the classification labels and confidence scores overlaid on
// the original image.
func Overlay(img image.Image, classifications Classifications) (image.Image, error) {
	gimg := gg.NewContextForImage(img)
	x := 30
	y := 30
	for _, classification := range classifications {
		// Skip unknown labels generated by Viam-trained models.
		if classification.Label() == "VIAM_UNKNOWN" {
			continue
		} else {
			rimage.DrawString(gimg,
				fmt.Sprintf("%v: %.2f", classification.Label(), classification.Score()),
				image.Point{x, y},
				color.NRGBA{255, 0, 0, 255},
				30)
			y += 30
		}
	}
	return gimg.Image(), nil
}
