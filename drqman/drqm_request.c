/* $Id: drqm_request.c,v 1.2 2001/07/17 10:23:11 jorge Exp $ */

#include <stdlib.h>
#include <unistd.h>

#include <libdrqueue.h>
#include "drqm_request.h"

void drqm_request_joblist (struct info_drqm_jobs *info)
{
  /* This function is called non-blocked */
  /* This function is called from inside drqman */
  /* It sends the information to the master about a finished task */
  struct request req;
  int sfd;
  struct job *tjob;	
  int i;

  if ((sfd = connect_to_master ()) == -1) {
    fprintf(stderr,"%s\n",drerrno_str());
    return;
  }

  req.type = R_R_LISTJOBS;

  send_request (sfd,&req,CLIENT);
  recv_request (sfd,&req,CLIENT);

  if (req.type == R_A_LISTJOBS) {
    info->njobs = req.data_s;
  } else {
    fprintf (stderr,"ERROR: Not appropiate answer to request R_R_TASKFINI\n");
    goto end;			/* Should I use gotos ? It seems like a reasonable option for this case */
  }

  clean_joblist (info);
  if ((info->jobs = malloc (sizeof (struct job) * info->njobs)) == NULL) {
    fprintf (stderr,"Not enough memory for job structures\n");
    goto end;
  }
  tjob = info->jobs;
  for (i=0;i<info->njobs;i++) {
    recv_job (sfd,tjob,CLIENT);
    tjob++;
  }

 end:
  close (sfd);
}

void clean_joblist (struct info_drqm_jobs *info)
{
  if (info->jobs) {
    free (info->jobs);
    info->jobs = NULL;
  }
}



