const char *colorname[] = {

  /* 8 normal colors */
  [0] = "#0d151f", /* black   */
  [1] = "#54687e", /* red     */
  [2] = "#68778b", /* green   */
  [3] = "#7b8799", /* yellow  */
  [4] = "#8a94a0", /* blue    */
  [5] = "#8b98a8", /* magenta */
  [6] = "#9299a5", /* cyan    */
  [7] = "#90949b", /* white   */

  /* 8 bright colors */
  [8]  = "#5c6571",  /* black   */
  [9]  = "#718BA8",  /* red     */
  [10] = "#8B9FBA", /* green   */
  [11] = "#A5B5CC", /* yellow  */
  [12] = "#B9C6D6", /* blue    */
  [13] = "#BACBE1", /* magenta */
  [14] = "#C3CCDD", /* cyan    */
  [15] = "#c2c4c7", /* white   */

  /* special colors */
  [256] = "#0d151f", /* background */
  [257] = "#c2c4c7", /* foreground */
  [258] = "#c2c4c7",     /* cursor */
};

/* Default colors (colorname index)
 * foreground, background, cursor */
 unsigned int defaultbg = 0;
 unsigned int defaultfg = 257;
 unsigned int defaultcs = 258;
 unsigned int defaultrcs= 258;
