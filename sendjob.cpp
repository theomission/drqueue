//
// $Id: sendjob.cpp,v 1.5 2004/10/09 05:21:43 jorge Exp $
// 
// To set up a maya job from a file and send it to the master
//

#include <fstream>
#include <iostream>
#include <string>
#include <unistd.h>

#ifdef __LINUX
#include <stdint.h>
#else
# ifdef __IRIX
#include <sys/types.h>
# else
#  error You need to define the OS, or OS defined not supported
# endif
#endif

#include "sendjob.h"
#include "libdrqueue.h"

int main (int argc,char *argv[])
{
  int opt;
	int toj = 0;
    
  presentation();

  while ((opt = getopt (argc,argv,"hvt:")) != -1) {
    switch (opt) {
    case 'v':
      //      show_version (argv);
      exit (0);
		case 't':
			toj = str2toj (optarg);
			break;
    case '?':
    case 'h':
      usage();
      exit (1);
    }
  }

  if ((argc < 2) || (toj == TOJ_NONE)) {
    usage ();
    exit (1);
  }

  
  std::ifstream infile(argv[1]);
	switch (toj) {
		case TOJ_MAYA:
  		if (RegisterMayaJobFromFile (infile)) {
				std::cerr << "Error registering MAYA job from file: " << argv[1] << std::endl;
    		exit (1);
  		}
			break;
		case TOJ_BLENDER:
  		if (RegisterBlenderJobFromFile (infile)) {
				std::cerr << "Error registering BLENDER job from file: " << argv[1] << std::endl;
    		exit (1);
  		}
			break;
	}

  std::cerr << "Job sent successfuly to the queue\n";

  exit (0);
}

void presentation (void)
{
  std::cout << "DrQueue - by Jorge Daza Garc�a Blanes\n\n";
}

void cleanup (int signum)
{
  exit(0);
}

void usage (void)
{
  std::cerr << "Usage: sendjob [-vh] -t <type> <job_file>\n"
						<< "Valid options:\n"
						<< "\t-v version information\n"
						<< "\t-h prints this help\n"
						<< "\t-t [maya|blender] type of job";
}

int RegisterMayaJobFromFile (std::ifstream &infile)
{
  // Job variables for the script generator
  struct job job;
  struct mayasgi mayaSgi;

  std::string owner;
  std::string jobName;
  std::string camera;
  int frameStart,frameEnd,frameStep;
  int resX,resY;
  std::string scenePath;
  std::string renderDir;
  std::string fileFormat;
  std::string image;
  char *pathToScript;

  getline(infile,owner);
  getline(infile,jobName);
  getline(infile,camera);
  infile >> frameStart;
  infile >> frameEnd;
  infile >> frameStep;
  infile >> resX;
  infile >> resY;
  getline(infile,scenePath);	// 
  getline(infile,scenePath);	// Get two times because '>>' leaves the pointer before \n 
  getline(infile,renderDir);
  getline(infile,fileFormat);
  getline(infile,image);

  strncpy(mayaSgi.file_owner,owner.c_str(),BUFFERLEN-1);
  strncpy(mayaSgi.camera,camera.c_str(),BUFFERLEN-1);
  mayaSgi.res_x = resX;
  mayaSgi.res_y = resY;
  strncpy(mayaSgi.scene,scenePath.c_str(),BUFFERLEN-1);
  strncpy(mayaSgi.renderdir,renderDir.c_str(),BUFFERLEN-1);
  strncpy(mayaSgi.format,fileFormat.c_str(),BUFFERLEN-1);
  snprintf(mayaSgi.scriptdir,BUFFERLEN,"%s/tmp/",getenv("DRQUEUE_ROOT"));
  strncpy(mayaSgi.image,image.c_str(),BUFFERLEN-1);

  if (!(pathToScript = mayasg_create(&mayaSgi))) {
    std::cerr << "Error creating script file\n";
    return 1;
  }

  strncpy (job.name,jobName.c_str(),MAXNAMELEN-1);
  strncpy (job.cmd,pathToScript,MAXCMDLEN-1);
  strncpy (job.owner,owner.c_str(),MAXNAMELEN-1);
  strncpy (job.email,owner.c_str(),MAXNAMELEN-1);
  job.frame_start = frameStart;
  job.frame_end = frameEnd;
  job.frame_step = frameStep;
  job.priority = 500;

  job.koj = KOJ_MAYA;
  strncpy (job.koji.maya.scene,scenePath.c_str(),BUFFERLEN-1);
  strncpy (job.koji.maya.renderdir,renderDir.c_str(),BUFFERLEN-1);
  strncpy (job.koji.maya.image,"",BUFFERLEN-1);
  strncpy (job.koji.maya.viewcmd,"",BUFFERLEN-1);

  job.limits.os_flags = OSF_LINUX;
  job.limits.nmaxcpus = -1;
  job.limits.nmaxcpuscomputer = -1;

  if (!register_job(&job)) {
    std::cerr << "Error sending job to the queue\n";
    return 1;
  }

  return 0;
}

int RegisterBlenderJobFromFile (std::ifstream &infile)
{
  // Job variables for the script generator
  struct job job;
  struct blendersgi blenderSgi;

  std::string jobName;
  int frameStart,frameEnd,frameStep;
  std::string scenePath;
  char *pathToScript;

  getline(infile,jobName);
  infile >> frameStart;
  infile >> frameEnd;
  infile >> frameStep;
  getline(infile,scenePath);	// 
  getline(infile,scenePath);	// Get two times because '>>' leaves the pointer before \n 

  strncpy(blenderSgi.scene,scenePath.c_str(),BUFFERLEN-1);
  snprintf(blenderSgi.scriptdir,BUFFERLEN,"%s/tmp/",getenv("DRQUEUE_ROOT"));

  if (!(pathToScript = blendersg_create(&blenderSgi))) {
		std::cerr << "Error creating script file\n";
    return 1;
  }

  strncpy (job.name,jobName.c_str(),MAXNAMELEN-1);
  strncpy (job.cmd,pathToScript,MAXCMDLEN-1);
  strncpy (job.owner,getenv("USER"),MAXNAMELEN-1);
  strncpy (job.email,getenv("USER"),MAXNAMELEN-1);
  job.frame_start = frameStart;
  job.frame_end = frameEnd;
  job.frame_step = frameStep;
  job.block_size = frameStep;
  job.priority = 500;

  job.koj = KOJ_BLENDER;
  strncpy (job.koji.blender.scene,scenePath.c_str(),BUFFERLEN-1);
  strncpy (job.koji.blender.viewcmd,"",BUFFERLEN-1);

  job.limits.os_flags = OSF_LINUX;
  job.limits.nmaxcpus = -1;
  job.limits.nmaxcpuscomputer = -1;

  if (!register_job(&job)) {
		std::cerr << "Error sending job to the queue\n";
    return 1;
  }

  return 0;
}

int str2toj (char *str)
{
	int toj = TOJ_NONE;

	if (strstr(str,"maya") != NULL) {
		toj = TOJ_MAYA;
	} else if (strstr(str,"blender") != NULL) {
		toj = TOJ_BLENDER;
	}

	return toj;
}

