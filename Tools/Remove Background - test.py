from rembg import remove
from PIL import Image

input_path = "IMG_test/4GGB107070A-JBLK.jpg"
output_path = "IMG_test/4GGB107070A-JBLK_test.jpg"

input = Image.open(input_path)

output = remove(input)
output.save(output_path)
