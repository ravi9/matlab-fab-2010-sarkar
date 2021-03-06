#include "header.h"

int    img_width, img_height ;     /* width and height of original image */
int    gksize, seg_focus_p;         /* size the image is expanded by */
int    exp_img_size, img_size ;    /* original and expanded image size */
int    expnd_width, expnd_height ; /* expanded width and height */
UCHAR    *image_ptr, *edge_ptr;      /*pointers to the image and edge data*/
float  b1, b2, b3, a0, a1, a2;     /* filter coefficients */
float  a01, a02, beta, alpha, tau_x, tau_y;
float    Gamma;
float  pi;
char  imgname[100], convlfilename[100];
float *convl_ptr, *dir_ptr, *slope_ptr;
int    mark_p, chain_p;
float norm_const;
float scale;


#define PLAIN

int MIN_SEG_LENGTH;
float SEG_INDEX = 200.0;
float MIN_DISTANCE = 0.5;

int  SEGMENT_P, OPERATOR = 2, MRC = 6;

float ACCPT_ERROR =  900.0;

int THRESHOLD_P, THRESH_VAL, THRESH_LENGTH;
float LOW_HYSTERESIS, HIGH_HYSTERESIS, LOW_TH, HIGH_TH;
int ATTS_FILE_P;
static int contour_id, parameter_id;


main(int argc, char **argv)
{

  struct chain *edge_chain;
  int i;

  if (argc < 3)
    {
      fprintf(stderr,  "Usage: %s img_file scale -edge 1/2 -mrc canny_mrc -lh Low Hysteresis -hh High Hysteresis -msl minimum_segmentation_length -si segmetation index -md minimum pixel deviation -lt Length Threshold -seg segment_p -o atts_file_p\n", *argv);
      fprintf(stderr,  "       - the thresholding, the segmenting, and the edge file flags are optional.\n");
      fprintf(stderr,  "       - slope_thresh refers to the threshold on the edge profile slope\n");
      fprintf(stderr,  "       - atts_file if you want the .atts file\n");
      exit(1);
    }

  /* default parameters */
  MIN_SEG_LENGTH = 10;
  THRESHOLD_P = THRESH_VAL = THRESH_LENGTH = 0;
  LOW_HYSTERESIS = 0.0; HIGH_HYSTERESIS = 0.0;
  SEGMENT_P = 0; ATTS_FILE_P = 0;

  SEG_INDEX = 200.0; MIN_DISTANCE = 0.5;

  strncpy(imgname, argv[1], 100) ;
  strcpy(convlfilename, imgname);

  scale = atof(argv[2]);
  for (i=3; i < argc; i++) {
    if (strcmp(argv[i], "-edge") == 0) {OPERATOR = atoi(argv[++i]);}
    if (strcmp(argv[i], "-lh") == 0) {
      THRESHOLD_P = 1; LOW_HYSTERESIS = atof(argv[++i]);
    }
    if (strcmp(argv[i], "-hh") == 0) {
      THRESHOLD_P = 1; HIGH_HYSTERESIS = atof(argv[++i]);
    }
    if (strcmp(argv[i], "-si") == 0) {
      SEGMENT_P = 1; SEG_INDEX = atof(argv[++i]);
    }
   if (strcmp(argv[i], "-md") == 0) {
      SEGMENT_P = 1;  MIN_DISTANCE = atof(argv[++i]);
    }
   if (strcmp(argv[i], "-msl") == 0) {
      SEGMENT_P = 1;   MIN_SEG_LENGTH = atof(argv[++i]);
    }
   /*if (strcmp(argv[i], "-st") == 0) {
      THRESHOLD_P = 1; THRESH_VAL = atoi(argv[++i]);
      }*/
   if (strcmp(argv[i], "-lt") == 0) {
       THRESH_LENGTH = atoi(argv[++i]);
   }
   if (strcmp(argv[i], "-seg") == 0) {SEGMENT_P = atoi(argv[++i]);}
   if (strcmp(argv[i], "-o") == 0) {
     ATTS_FILE_P = 1; strcpy(convlfilename, argv[++i]);
   }
   if (strcmp(argv[i], "-mrc") == 0) {MRC = atoi(argv[++i]);}
  }
  
  read_image (imgname, &image_ptr);
  edge_chain = NULL;
  
  Gamma = scale;
  tau_x = 1.0;
  tau_y = 1.0;
  beta = 1.0 / Gamma;
  pi = 22.0/7.0;
  alpha = 0.312;


  zero_cross_filter();
  edge_chain = chain_coder();
  if (SEGMENT_P == 1) edge_chain = segment(edge_chain);
  if (THRESH_LENGTH > 0) {
    threshold_edges_length (edge_chain, THRESH_LENGTH);
  }
  /*else { threshold_edges (edge_chain, (float) THRESH_VAL);
  if (THRESHOLD_P == 1) {
    threshold_edges (edge_chain, HIGH_TH);
    }*/
  if (ATTS_FILE_P == 1) {
    add_atts_lists(edge_chain);
  }
  write_chain(convlfilename, &(edge_chain));
}

/*******************************************/
static int getint(FILE *fp)
{
  int item, i, flag;

  /* skip forward to start of next number */
  item  = getc(fp); flag = 1;
  do {

    if (item =='#') {   /* comment*/
      while (item != '\n' && item != EOF) item=getc(fp);
    }

    if (item ==EOF) return 0;
    if (item >='0' && item <='9') 
      {flag = 0;  break;}

    /* illegal values */
    if ( item !='\t' && item !='\r' 
	&& item !='\n' && item !=',') return(-1);

    item = getc(fp);
  } while (flag == 1);


  /* get the number*/
  i = 0; flag = 1;
  do {
    i = (i*10) + (item - '0');
    item = getc(fp);
    if (item <'0' || item >'9') {
      flag = 0; break;}
    if (item==EOF) break; 
  } while (flag == 1);
  
  return i;
}
/*************************************************************/
int read_image (char *imgname, UCHAR **image)
{
  UCHAR    *dest, pix1, *temp1;
  FILE     *img_file ;
  int      i, j;
  int      x, y, first_line;
  char     str[100];

  /* In the process of reading in the image we will repeat
     the boundries of the image 5(Gamma) times + 3 */

  if((img_file = fopen( imgname, "r")) == NULL)
    {
      fprintf(stderr, "Cannot open file %s for reading.\n", imgname) ;
      exit(1) ;   /* return(NOOK) ; */
    }
  fscanf(img_file, "%s", str) ;
  if (strcmp (str, "P5") != 0) {
    fprintf(stderr, "\n Image file %s not in PGM format", imgname);
    return(0);
  }
  img_width = getint(img_file);
  img_height = getint(img_file);
  fscanf(img_file, "%d", &i) ;

  if ((img_height < 0) || (img_width < 0)) {
    fprintf(stderr, "\n Image file %s not in PGM format", imgname);
    return(0);
  }
  display_main(" Reading image file") ;
  
  /* The size of the image is expanded by the size of the edge 
     detection kernal */
  Gamma = scale;
  gksize = 5*ceil(Gamma)+ 3;
  expnd_width = img_width + 2*gksize ;
  expnd_height = img_height + 2*gksize ;
  exp_img_size = expnd_width * expnd_height ;
  img_size = img_width * img_height ;

  if (((*image) = (UCHAR *) malloc(exp_img_size * sizeof(UCHAR)))    == NULL)
    {
      fprintf(stderr, "Problems allocating memory for image") ;
      exit(1) ;  /* return(NOOK) ; */
    }

  
  dest = *image ;
  *dest = (UCHAR)getc(img_file) ;   /* dummy read to get rid of line-feed that
				       hangs around after the fscanf */
  
  first_line = img_height - 1 ;
  for( y = img_height; y; y-- )
    {
      if( y == first_line )
	{
	  temp1 = dest ;
	  for( j = gksize; j; j--)  /* copy the first line gksize times */
	    for( i = expnd_width; i; i-- )
	      *dest++ = *(temp1 - i ) ;
	}
      pix1 = (UCHAR)getc(img_file) ; /*get first pixel, put it in image*/
      for( j = gksize+1; j; j-- ) /* and copy it gksize times */
	*dest++ = pix1 ;
      for( x = img_width-2; x; x-- )
	*dest++ = (UCHAR)getc(img_file) ;
      pix1 = (UCHAR)getc(img_file) ;  /* get the last pixel, put it in image */
      for( j = gksize+1; j; j-- )     /* and copy it gksize times */
	*dest++ = pix1 ;
    }
  temp1 = dest ;
  for( j = gksize; j; j-- )            /* copy the last line gksize times */
    for( i = expnd_width; i; i-- )
      *dest++ = *(temp1 - i) ;
  
  fclose(img_file) ;
 
}  

/****************************************************************************/
int display_main (char msg[500])
{
  return;
  fprintf(stderr, "\n %s", msg);
  return;

}
