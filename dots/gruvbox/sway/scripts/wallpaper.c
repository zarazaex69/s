#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#define M_PI 3.14159265358979323846

typedef struct {
    float r, g, b;
} Color;

// interpolate between two colors
Color interpolate_colors(Color c1, Color c2, float t) {
    Color result;
    result.r = c1.r + t * (c2.r - c1.r);
    result.g = c1.g + t * (c2.g - c1.g);
    result.b = c1.b + t * (c2.b - c1.b);
    return result;
}

// pick gradient colors based on time of day
void get_time_colors(float time_val, Color *top, Color *bottom) {
    Color c_night_t = {10.0f, 10.0f, 25.0f},
          c_night_b = {5.0f, 5.0f, 15.0f};
    Color c_dawn_t  = {200.0f, 100.0f, 80.0f},
          c_dawn_b  = {100.0f, 50.0f, 60.0f};
    Color c_noon_t  = {100.0f, 200.0f, 255.0f},
          c_noon_b  = {180.0f, 230.0f, 255.0f};
    Color c_dusk_t  = {80.0f, 40.0f, 100.0f},
          c_dusk_b  = {250.0f, 120.0f, 80.0f};

    if (time_val < 6.0f) {
        float t = time_val / 6.0f;
        *top    = interpolate_colors(c_night_t, c_dawn_t, t);
        *bottom = interpolate_colors(c_night_b, c_dawn_b, t);
    } else if (time_val < 12.0f) {
        float t = (time_val - 6.0f) / 6.0f;
        *top    = interpolate_colors(c_dawn_t, c_noon_t, t);
        *bottom = interpolate_colors(c_dawn_b, c_noon_b, t);
    } else if (time_val < 18.0f) {
        float t = (time_val - 12.0f) / 6.0f;
        *top    = interpolate_colors(c_noon_t, c_dusk_t, t);
        *bottom = interpolate_colors(c_noon_b, c_dusk_b, t);
    } else {
        float t = (time_val - 18.0f) / 6.0f;
        *top    = interpolate_colors(c_dusk_t, c_night_t, t);
        *bottom = interpolate_colors(c_dusk_b, c_night_b, t);
    }
}

int main(int argc, char *argv[]) {
    if (argc != 6) {
        fprintf(stderr,
            "usage: %s width height time(0.0-24.0) grain angle_deg\n",
            argv[0]);
        return 1;
    }

    int width     = atoi(argv[1]);
    int height    = atoi(argv[2]);
    float time_val = atof(argv[3]);
    int base_grain = atoi(argv[4]);
    float angle_deg = atof(argv[5]);

    if (time_val < 0.0f || time_val > 24.0f)
        time_val = 0.0f;

    unsigned char *img = malloc(width * height * 3);
    if (!img) return 1;

    srand(1337);

    Color top_color, bottom_color;
    get_time_colors(time_val, &top_color, &bottom_color);

    // project pixel coords onto gradient axis
    float angle_rad = angle_deg * M_PI / 180.0f;
    float dx = cos(angle_rad);
    float dy = sin(angle_rad);

    float pw0 = width * dx, p0h = height * dy, pwh = width * dx + height * dy;
    float proj_min = 0, proj_max = 0;

    if (pw0 < proj_min) proj_min = pw0;
    if (p0h < proj_min) proj_min = p0h;
    if (pwh < proj_min) proj_min = pwh;

    if (pw0 > proj_max) proj_max = pw0;
    if (p0h > proj_max) proj_max = p0h;
    if (pwh > proj_max) proj_max = pwh;

    float proj_range = proj_max - proj_min;

    int idx = 0;
    for (int y = 0; y < height; y++) {
        float y_proj = y * dy;
        for (int x = 0; x < width; x++) {
            float proj_val = x * dx + y_proj;
            float t = (proj_val - proj_min) / proj_range;
            if (t < 0.0f) t = 0.0f;
            if (t > 1.0f) t = 1.0f;

            float cr = top_color.r + t * (bottom_color.r - top_color.r);
            float cg = top_color.g + t * (bottom_color.g - top_color.g);
            float cb = top_color.b + t * (bottom_color.b - top_color.b);

            int noise = (rand() % (base_grain * 2 + 1)) - base_grain;
            int r = (int)cr + noise;
            int g = (int)cg + noise;
            int b = (int)cb + noise;

            img[idx++] = (r < 0) ? 0 : (r > 255 ? 255 : r);
            img[idx++] = (g < 0) ? 0 : (g > 255 ? 255 : g);
            img[idx++] = (b < 0) ? 0 : (b > 255 ? 255 : b);
        }
    }

    // output raw ppm to stdout
    printf("P6\n%d %d\n255\n", width, height);
    fwrite(img, 1, width * height * 3, stdout);
    free(img);
    return 0;
}
