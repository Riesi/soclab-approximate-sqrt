#######################################################
# Copyright (C) 2021 Simon Michael Laube under AGPLv3
#######################################################
# Prerequisites: pip3 install PySerial
import serial
from serial.tools import list_ports
import io
import numpy as np
import matplotlib.pyplot as plt
import threading
import time

# Global settings
PORT="COM0" # preliminary port, will be changed below by user input!
BAUD=9600 # baudrate
SIZE=serial.EIGHTBITS # 1 byte data frame
TIMEOUT= 10 # timeout in seconds


def int16_to_bytes(a):
    """
    Takes a list of (16bit) integers and returns a list
    of (8bit) integers with double the size.
    """
    r=[]
    for e in a:
        e = int(e)
        HB=e//(2**8)
        LB=e%(2**8)
        r.append(LB) #LOW
        r.append(HB) #HIGH
    return r

def save_binary(fname,data,mode):
    """
    Saves a binary image of the data provided as an integer numpy array
    mode=True ... data is 16bit
    mode=False... data is 8bit
    """
    # Convert numpy array to list
    data=data.reshape(1,-1)[0]
    data=data.tolist()
    # Write binary file
    f=open(fname,'w+b')
    if(mode):
        binary=bytearray(int16_to_bytes(data))
        f.write(binary)
    else:
        binary=bytearray(data)
        f.write(binary)
    f.close()

def PSNR_RGB(ORIG, CMPR):
    """
    Calculates the peak-SNR of an RGB image 'CMPR' with respect to the original image 'ORIG'.
    Both images are in float representation (their values are in [0,1])
    """
    M=ORIG.shape[0] # rows
    N=ORIG.shape[1] # columns
    CH=ORIG.shape[2] # color channels

    MAXI=1 # 1 for float representation, 255 for 8bit representation

    # https://en.wikipedia.org/wiki/Peak_signal-to-noise_ratio
    MSE=np.sum((ORIG-CMPR)**2)*1/(CH*M*N)
    PSNR=10*np.log(MAXI**2/MSE)/np.log(10)

    return PSNR



# List devices for the user to select one
devices=serial.tools.list_ports.comports()
print("\tDevice\t\tDescription\tUSB PID\tLocation\tProduct")
for idx, e in enumerate(devices):
    print("["+str(idx)+"]\t"+str(e.device)+"\t"+str(e.description)+"\t\t"+str(e.pid)+"\t"+str(e.location)+"\t\t"+str(e.product))
mydevice=input("Select device: ")
mydevice=int(mydevice)
# Set port according to selection of user
PORT=devices[mydevice].device

try:
    S_int = list(range(2**0-1,2**12-1))
    
    #imname="test.png"
    #imname="cosmo_lowres.png"
    imname=input("Input image path: ")

    # Read image
    img = plt.imread(imname,format="RGB")


    R_img=img[:,:,0] # Red part
    G_img=img[:,:,1] # Green part
    B_img=img[:,:,2] # Blue part
    # The pixels are normalized to [0,1] -> convert to 16bit integers
    R_int=(R_img*(2**16-1)).astype(int).reshape(1,-1)[0]
    G_int=(G_img*(2**16-1)).astype(int).reshape(1,-1)[0]
    B_int=(B_img*(2**16-1)).astype(int).reshape(1,-1)[0]
    #Stack colors into one bytearray
    S_int=np.array([R_int,G_int,B_int]).reshape(1,-1)[0]
    #S_int  = S_int.tolist()
    # Convert to bytearray
    S_arr=int16_to_bytes(S_int)

    # Append dummy bytes for last readout
    S_arr.append(0)
    S_arr.append(0)
    
    # Open Port (1 stopbit, no parity bit)
    serialPort= serial.Serial(port=PORT, baudrate=BAUD, parity=serial.PARITY_EVEN, bytesize=SIZE, timeout=TIMEOUT, stopbits=serial.STOPBITS_TWO, rtscts=False, dsrdtr=False)
    print("COM port opened. You are using "+serialPort.name)
    time.sleep(3) # delay necessary for arduino / serial interface flow control
    
    data=[]
    
    total_len=len(S_arr)//2
    rcv_count=0
    # Stream and receive serial data
    for i in range(total_len):
        # Write 2 bytes
        serialPort.write(S_arr[2*i:2*i+1])
        serialPort.write(S_arr[2*i+1:2*i+2])
        
         # Read 1 byte
        tmp=serialPort.read(size=1)
        data.append(int(tmp[0]))
        # Discard first data byte
        if(i>0):
            rcv_count+=1
            
            ##### PROGRESS BAR #####
            print("Progress: ",end="")
            for k in range(int((rcv_count/total_len*100)//5)):
                print("#",end="")
            print("    {:.2f}".format(rcv_count/total_len*100)+" %")
            #########################
            print("Sent: "+str(S_arr[2*(i-1)]+S_arr[2*(i-1)+1]*256)+" --->>>  Received: "+str(int(data[-2])))
  
    print("\n")
    
    serialPort.close()
    print("COM port closed.\nBye.")
    #delete last byte
    data= data[:-1]
    
    # Convert data to images
    R_data=np.array(data[0:R_int.shape[0]]).reshape(R_img.shape[0],R_img.shape[1])
    G_data=np.array(data[R_int.shape[0]:R_int.shape[0]+G_int.shape[0]]).reshape(G_img.shape[0],G_img.shape[1])
    B_data=np.array(data[R_int.shape[0]+G_int.shape[0]:]).reshape(B_img.shape[0],B_img.shape[1])
    newimg=np.zeros((img.shape[0],img.shape[1],img.shape[2]))
    newimg[:,:,0]=R_data
    newimg[:,:,1]=G_data
    newimg[:,:,2]=B_data

    newimg_float=(newimg**2).astype(float)/2**16
    # analyse data   
    plt.figure(3)
    plt.scatter(S_int,data)
    plt.scatter(S_int,np.sqrt(S_int))
    
    #figures
    
    plt.figure(1)
    plt.subplot(2,2,1)
    plt.imshow(img)
    plt.subplot(2,2,2)
    plt.imshow(newimg_float)

    plt.subplot(2,1,2)
    in_data = S_arr[0:np.shape(S_arr)[0]-2:2]
    out_data = data
    plt.scatter(in_data,data)
    plt.show()
    # Close Port
    plt.imsave(imname+"_compr.png",newimg_float)
    save_binary(imname+".img",S_int,True)    
    save_binary(imname+"_compr.img",newimg.astype(int),False)    
    # Calc PSNR   
    print("PSNR = "+"{:.2f}".format(PSNR_RGB(img,newimg_float))+" dB")

except Exception as e:
    print("Wrong filename or other error during image processing.")
    print(e)





# Testing image IO
# testdata=np.arange(0,2**16).reshape(-1,2**8)
# cmpr=np.sqrt(testdata).astype(int)
# cmprsqr=cmpr**2
# plt.imsave("rawtest.png",testdata)
# plt.imsave("cmprtest.png",cmprsqr)
# save_binary("rawtest.img",testdata,True)
# save_binary("cmprtest.img",cmpr,False)
