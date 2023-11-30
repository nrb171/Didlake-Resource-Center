#This file will download the TCPRIMED dataset from AWS S3 servers. This is a
#large dataset, so it will take a while to download.

#In order for this to run, you will need to have boto3 installed in your python
#environment. The base python environment on the PSU METEO servers DOES have
#this package installed, so once your activate python you will be able to run
#this file.

#In a bash terminal that meets all prerequisites, type "python get_TCPRIMED.py"
#to run this file. The data will be downloaded to the directory specified below
#in a format that is consistent with the TCPRIMED website.

outFolder = '/rita/s1/nrb171/TCPRIMED/'


# ************************* INITIALIZING ENVIRONMENT ************************* #
import boto3
#we can use the unsigned config to access public buckets
from botocore import UNSIGNED
from botocore.client import Config
import os as os
import time as time

def progress_bar(progress, total):
    print(' '*80, end = '\r')
    percent = progress/(total)*100
    bar = chr(9608) *int(percent/5) + '-'*(20 - int(percent/5))
    print(f"\r|{bar}| {percent:.2f}%", end ='')


# ***************************** CREATE THE CLIENT **************************** #
bucketName = 'noaa-nesdis-tcprimed-pds'
s3Client = boto3.client('s3', config=Config(signature_version=UNSIGNED))
s3 = boto3.resource('s3', config=Config(signature_version=UNSIGNED))
bucket = my_bucket = s3.Bucket(bucketName, )


# ************************* SETUP ENVIRONMENT DETAILS ************************ #

#grandparent = 'v01r00/final/'
years = ['1998', '1999', '2000', '2001', '2002', '2003', '2004', '2005', '2006', '2007', '2008', '2009', '2010', '2011', '2012', '2013', '2014', '2015', '2016', '2017', '2018', '2019', '2020', '2021']
# regions = ['AL','EP,','CP', 'IO','SH','WP']
regions =["EP"]


# ***************************** DOWNLOAD THE DATA **************************** #

t1=time.time()
t0=time.time()

keyErrors = []
dlCounter = 0
for year in years:
    # ********************* MAKE A DIRECTORY FOR THE YEAR ******************** #
    try:
        os.mkdir(outFolder+year)
    except:
        fu='BAR'

    for region in regions:
        #update progress
        t1 = time.time()
        dlCounter += 1
        timeRemaining = round((t1-t0)/3600*(1-(len(years)*len(regions))/(dlCounter)),2)
        progress_bar(dlCounter, len(years)*len(regions))
        print(' | eta: ', timeRemaining,'hrs', end='')
        print(' | downloading: '+ year+region, end='', flush=True)

        for id in range(1, 1000):
            #get the list of files for the storm
            idStr = str(id).zfill(2)
            storms = s3Client.list_objects_v2(Bucket=bucketName, Prefix='v01r00/final/'+year+'/'+region+'/'+idStr+'/')

            # ******** IF THERE ARE NO FILES, SKIP TO THE NEXT REGION ******** #
            if storms['KeyCount'] == 0:
                break
            else:
                # ****************** POPULATE THE FILE LIST ****************** #
                fileList = []
                for key in storms['Contents']:
                    fileList.append(key['Key'])

                # ********* MAKE A DIRECTORY FOR THE STORM AND REGION ******** #
                #regionfolder
                try:
                    os.mkdir(outFolder+year+'/'+region)
                except:
                    fu='BAR'
                #stormfolder
                try:
                    os.mkdir(outFolder+year+'/'+region+'/'+idStr)
                except:
                    fu='BAR'

                # ************ DOWNLOAD THE FILES TO THE OUTFOLDER *********** #
                for file in fileList:
                    fileName = file.split('/')[-1]

                    #If the file already exists, skip it
                    if os.path.isfile(outFolder+year+'/'+region+'/'+idStr+'/'+fileName):
                        continue

                    try:
                        #download the file
                        s3Client.download_file(bucketName, file, outFolder+year+'/'+region+'/'+idStr+'/'+fileName)
                    except:
                        #if there is an error, add the file to the keyErrors list
                        keyErrors.append(file)

                        #update the output.log file
                        with open('./output.log', 'a') as f:
                            f.write(file+'\n')
                            f.close()


keyErrors

# *********************************** DONE *********************************** #
