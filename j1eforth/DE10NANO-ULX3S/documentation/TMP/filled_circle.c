void DrawFilledCircle(int x0, int y0, int radius)
{
    int x = radius;
    int y = 0;
    int xChange = 1 - (radius << 1);
    int yChange = 0;
    int radiusError = 0;

    while (x >= y)
    {
        for (int i = x0 - x; i <= x0 + x; i++)
        {
            SetPixel(i, y0 + y);
            SetPixel(i, y0 - y);
        }
        for (int i = x0 - y; i <= x0 + y; i++)
        {
            SetPixel(i, y0 + x);
            SetPixel(i, y0 - x);
        }

        y++;
        radiusError += yChange;
        yChange += 2;
        if (((radiusError << 1) + xChange) > 0)
        {
            x--;
            radiusError += xChange;
            xChange += 2;
        }
    }
} 
