// http://tech-algorithm.com/articles/drawing-line-using-bresenham-algorithm/
public void line(int x,int y,int x2, int y2, int color) {
    int w = x2 - x ;
    int h = y2 - y ;
    int dx1 = 0, dy1 = 0, dx2 = 0, dy2 = 0 ;
    if (w<0) dx1 = -1 ; else if (w>0) dx1 = 1 ;
    if (h<0) dy1 = -1 ; else if (h>0) dy1 = 1 ;
    if (w<0) dx2 = -1 ; else if (w>0) dx2 = 1 ;
    int longest = Math.abs(w) ;
    int shortest = Math.abs(h) ;
    if (!(longest>shortest)) {
        longest = Math.abs(h) ;
        shortest = Math.abs(w) ;
        if (h<0) dy2 = -1 ; else if (h>0) dy2 = 1 ;
        dx2 = 0 ;            
    }
    int numerator = longest >> 1 ;
    for (int i=0;i<=longest;i++) {
        putpixel(x,y,color) ;
        numerator += shortest ;
        if (!(numerator<longest)) {
            numerator -= longest ;
            x += dx1 ;
            y += dy1 ;
        } else {
            x += dx2 ;
            y += dy2 ;
        }
    }
}

//https://blog.demofox.org/2015/01/17/bresenhams-drawing-algorithms/
// Draw an arbitrary line.  Assumes start and end point are within valid range
// pixels is a pointer to where the pixels you want to draw to start aka (0,0)
// pixelStride is the number of unsigned ints to get from one row of pixels to the next.
// Usually, that is the same as the width of the image you are drawing to, but sometimes is not.
void DrawLine(unsigned int* pixels, int pixelStride, int x1, int y1, int x2, int y2, unsigned int color)
{
    // calculate our deltas
    int dx = x2 - x1;
    int dy = y2 - y1;
 
    // if the X axis is the major axis
    if (abs(dx) >= abs(dy))
    {
        // if x2 < x1, flip the points to have fewer special cases
        if (dx < 0)
        {
            dx *= -1;
            dy *= -1;
            swap(x1, x2);
            swap(y1, y2);
        }
 
        // get the address of the pixel at (x1,y1)
        unsigned int* startPixel = &amp;pixels[y1 * pixelStride + x1];
 
        // determine special cases
        if (dy > 0)
            DrawLineMajorAxis(startPixel, 1, pixelStride, dx, dy, color);
        else if (dy < 0)
            DrawLineMajorAxis(startPixel, 1, -pixelStride, dx, -dy, color);
        else
            DrawLineSingleAxis(startPixel, 1, dx, color);
    }
    // else the Y axis is the major axis
    else
    {
        // if y2 < y1, flip the points to have fewer special cases
        if (dy < 0)
        {
            dx *= -1;
            dy *= -1;
            swap(x1, x2);
            swap(y1, y2);
        }
 
        // get the address of the pixel at (x1,y1)
        unsigned int* startPixel = &amp;pixels[y1 * pixelStride + x1];
 
        // determine special cases
        if (dx > 0)
            DrawLineMajorAxis(startPixel, pixelStride, 1, dy, dx, color);
        else if (dx < 0)
            DrawLineMajorAxis(startPixel, pixelStride, -1, dy, -dx, color);
        else
            DrawLineSingleAxis(startPixel, pixelStride, dy, color);
    }
}
