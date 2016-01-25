#include <strings.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>

/***********************************************/
#define UINT unsigned int
#define UCHAR unsigned char
#define OK 1
#define NOOK 0
#define MAX_SEGS_PER_CHAIN 50
#define DEBUG_ON
#define PI 3.142


#ifdef DEBUG_ON 
#define DEBUG \
  fprintf(stderr, "\n Reached line %d in file %s", __LINE__, __FILE__); 
#else 
#define DEBUG 
#endif



extern int    img_width, img_height ; /* width and height of original image */
extern int    gksize, seg_focus_p;      /* size the image is expanded by */
extern int    exp_img_size, img_size ; /* original and expanded image size */
extern int    expnd_width, expnd_height ; /* expanded width and height */
extern UCHAR    *image_ptr, *edge_ptr;  /*pointers to the image and edge data*/
extern float  b1, b2, b3, a0, a1, a2;     /* filter coefficients */
extern float  a01, a02, beta, alpha, tau_x, tau_y;
extern float  pi;
extern float    Gamma;
extern int OPERATOR, MRC;
extern char   convlfilename[100];
extern float *convl_ptr, *dir_ptr, *slope_ptr;
extern int    mark_p, chain_p;
extern float norm_const;
extern float start_scale, stop_scale;
extern int const_step;
extern float similarity, step;
extern int no_of_steps;
extern int MIN_SEG_LENGTH;
extern float SEG_INDEX;
extern float MIN_DISTANCE;
extern float ACCPT_ERROR;
extern int ATTS_FILE_P;
extern int EDGES_P, CHAIN_P, SEGMENT_P, FOCUS_P;

extern int THRESHOLD_P, THRESH_VAL, OPTIC_FLOW_P;
extern float LOW_HYSTERESIS, HIGH_HYSTERESIS, LOW_TH, HIGH_TH;
extern char optic_flow_file[100];

typedef struct scale_data {
  char name[100];
  float scale;
  struct chain *chain_code;
  struct scale_data *next;
} Scale_data;

extern struct scale_data *coarse;
extern struct scale_data *fine;


typedef struct c_element {
  int x;
  int y;
  float curvature;
  int dir;
  int tan_dir;
  float slope;
  float mag_plus;
  float width_plus;
  float mag_minus;
  float width_minus;
  float slope_ratio;
  float grad_dir;
  struct c_element *next;
} Element;

typedef struct chain {
  int id;
  int start_x;
  int start_y;
  int end_x;
  int end_y;
  int delete_p; /* used to mark deleted edge chains */
  float radius;
  float xc;
  float yc;
  float fit_error;
  struct c_element *start;
  struct chain *next;
} Chain;


typedef struct int_list {
  int value;
  struct int_list *next;
} Int_list;


typedef struct count {
  int value;
  struct interval *section;
} Count;

typedef struct interval {
  int start_i;
  int end_i;
  struct interval *next;
} Interval;

typedef struct seg_list {
  int begin;
  int end;
  int type;
  struct seg_list *next;
} Seg_list;


typedef struct point_list {
  int i;
  struct point_list *next;
} Point_list;

/* In lola.c */

extern unsigned long  gray_levels[264];


int display_main (char msg[500]);

/* In common.c */
float my_pow (float x, float d);
int slstore3(struct scale_data *i, struct scale_data **last, 
	     struct scale_data **start);
float cot (float x);
int save_edges(UCHAR *zcptr, char  filename[]);
int save_convl(float *convlptr, char  file2[]);
float angle_diff (float theta1, float theta2);
int length (struct int_list *list);
int delete_list (struct int_list *head);
int append_element (struct int_list **list, int value);
int delete_Elements (Element *head);
int print_list (struct int_list *list);
int cons_element (struct int_list **list, int value);
int max(int x, int y);
int min(int x, int y);
float my_fmax(double x, double y);
float my_fmin(double x, double y);
int consistent (int dir1, int dir2);
int reverse_list (struct c_element **start);


/* In focus.c */
float compute_ds (float sigma);
int trace_ctrs(Scale_data *scale1, Scale_data *scale2);


/* In chain.c */
int write_chain (char filename[100], struct chain **start);
void slstore(struct chain *i, struct chain **last, struct chain **start);
void insert_Element (Element **head, Element *ei);
int num_of_neighbor (UCHAR *point);
struct chain *chain_coder ();
int grow_seed (UCHAR *present,  struct c_element **last, int x, int y);
int get_attbs(UCHAR *edge, struct c_element *f_list);
int chain_length (Element *list);
void print_chain (Element *list);
void element_append (Element **chain, int i, int j);
int nth_x (int index, Element *list);
int nth_y (int index, Element *list);
int add_atts_lists (struct chain *chain_code);;
int chain_count (Chain *list);
Chain  *nth_chain (int n, Chain *list);


/* In ozco.c */
int zero_cross_filter();
int derivy_convl (UCHAR *imgptr, float *outptr);
int derivx_convl (UCHAR *imgptr, float *outptr);
int projec_convl (float *vector,  int size);
int opt_convl (float *vector,  int size);
int half_projec_convl  (float *vector, int size);
int half_opt_convl  (float *vector,  int size);


/* In segment.c */
int sense (float x1, float y1, float x2, float y2, float x3, float y3);
float determinant_3x3(float a00, float a01, float a02, float a10, 
                      float a11, float a12, float a20, float a21, float a22);
float get_fit_error_str(Element *edge_chain, int i, int j,
                        Element **type);
float get_fit_error_cir(Element *edge_chain, int i, int j,
                        Element **type);
float get_farthest (Element *edge_chain, int i, int j, int *index);
int get_candidate_points (Element *input, int i1, int i2, 
                          int *output);
int greater (float x, float y);
float my_sum (float x, float y);
void display_path (int path[50][50], int i, int j, int flag, 
                  struct int_list **min_p);
void display_fmat (float adj[50][50], int n);
void display_mat (int adj[50][50], int n);
float shortest_cycle (float adjacency[50][50], int n, 
                      struct int_list **vertices, int closed_p);
void get_best_fit_mixed(Element *input, Int_list **output, 
			Element **types_out, int num, int closed_p);
int neighbor_8_p (int x1, int y1, int x2, int y2);
int extract (Element *edge_xy, int i, int j, int *sx, int *sy, int *ex,
             int *ey, Element **output) ;
Chain *segment (Chain *edge_chain) ;




/* In thresh.c */
int threshold_edges (Chain *edges, float thresh);
int threshold_edges_length (Chain *edges, int length_thresh);
int compute_low_high_hys_thresh (UCHAR *edges, float *slopes, float LH, 
				 float HH, float *LTH, float *HTH);


/* In optic_flow.c */
int get_flow_attbs (int i, int j, Element *pixel, int width);
int compute_flow_parameters (float *flow_x, float *flow_y, int height,
			     int width);
int write_optic_flow (float *flow_x, float *flow_y, int img_height,
		      int img_width, char *filename);
int read_optic_flow (float **flow_x, float **flow_y, int *totx,
                     int *toty, char *filename);
int initialize_flow_parameters (char *filename);


