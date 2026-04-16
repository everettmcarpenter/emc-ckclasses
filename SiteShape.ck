public class SiteShape
{
    // enumerated colors
    // 0 = default, 1 = offwhite, 2 = grayish orange, 3 = pinkish grey, 4 = grey purple, 5 = yellow, 6 = green, 7 = pink, 8 = grey brown
    int color;
    // enumerated patterns
    // 0 = none, 1 = dots, 2 = vlines, 3 = hlines, 4 = slant, 5 = triangles, 6 = circles
    int pattern;
    // enumerated types
    // 0 = sun, 1 = stars, 2 = mountains, 3 = river, 4 = sky-others, 5 = tree
    int type;
    // has exploded
    int exploded;
    // is moving
    int moving;
    // state (has something changed)
    int state;
}