Notes of the Experimental Cube:

Vertices:

Vertices are stored in the bitmap variable where 1 is a negative number and 0 is a positive number.

Example:

For (0.5, -0.5, 0.5) you would get 010.

Put all 8 vertices together and you get the bitmap I have in there

Indices:

It gets split up into 12 separate bitmaps for each triangle.

Example:

(0, 1, 2) turns into

(2 << 8) | (1 << 4) | 0,