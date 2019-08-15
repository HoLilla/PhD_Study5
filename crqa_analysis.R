library('crqa')
library('entropy')
library('nonlinearTseries')
library('plot3D')
library('SDMTools')
library('tseriesChaos')
library('zoo')
library('gtools')

#mydata[i]<-read.csv(as.character(temp[i,]),header = FALSE)
#C:\Users\hodos\Desktop\PHD 2019\Study 5\study5_pilot\HR_RR_for_CRQA

setwd("C:/Users/hodos/Desktop/PHD_2019/Study_5/study5_pilot/HR_RR_for_CRQA")
files <- data.frame(mixedsort(list.files(pattern="*.txt")))
ID<-mixedsort(gsub("*_HR_RR.txt","", list.files(pattern="*.txt")))
ID_sub<-substr(ID,start = 1, stop = 4)
ID_Apple = NULL
ID_Banana = NULL 
for (k in 1:(length(ID)/6)){
ID_Apple<-c(ID_Apple,paste(ID_sub,"Apple",toString(k),sep = ""))
ID_Banana<-c(ID_Banana,paste(ID_sub,"Banana",toString(k),sep = ""))
}
ID_combined<-c(rbind(ID_Apple,ID_Banana))

mydata<-NULL
apples<-NULL
bananas<-NULL

  for (i in 1:length(ID)){
    temp<- read.delim(as.character(files[i,]), skip =3,header = FALSE)
  mydata<- cbind(mydata,temp$V1,temp$V2)
  apples <- cbind(apples,temp$V1)
  bananas <- cbind(bananas,temp$V2)
}

#mydata <-read.delim('NAC_Vivien_Lilla_HR_RR.txt', skip =3, header = FALSE)
mydata<-data.frame(mydata)
apples<-data.frame(apples)
bananas<-data.frame(bananas)
names(mydata)<- ID_combined
names(apples)<-ID_Apple
names(bananas)<-ID_Banana
#generate seq of data point of the Lorenx-system dynamics
#lorData1 <- lorenz(time = seq(0, 20, by = 0.02), do.plot = F)

#To generate the particular dynamics, the parameters sigma,
#rho, and beta have to be set, which we use here in their 
#default- settings of the lorenz()-function (σ = 10; ρ = 28; β = 8/3)

#embedding dimensions m - how many times apply the delay
# the delay d, the radius r, and the rescaling norm.
delay_parameters<- NULL
dimensions<- NULL

for (p in 1:length(mydata)){
  mut<- mutual(na.remove(mydata[,p],lag.max = 50)) # run average mutual information for mydata$exp_1 
  #the bit below is for local minimum
  delay <- as.zoo(mut)
  rdelay <- rollapply(delay, 3, function(mut) which.min(mut)==2)
  delay_parameters[p]<- index(rdelay)[coredata(rdelay)][1]
  
  fnn<-false.nearest(na.remove(mydata[,p]),m = 10, d = 9, t = 0) # run false-nearest-neighbor analysis 
  #plot(fnn) # plot results of fnn analysis of ad_1
  dimensions[p]<- which.min(round(fnn[1,], digits = 2))
}
#In fact, building a recurrence plot on a 3 vs. 
#4-dimensional phase-space will leads to very similar results,
#and as a rule of thumb, it 
#is advisable to slightly over-embed (i.e., pick 
#an embedding dimension slightly higher than the estimate) when in doubt.

#keep norm data the same across the analysis

#%REC shouldn't be too low or high, for physiological data 1-2%
#Although there are several rules of thumb for the choice of a radius, One alternative is to run the 
#data sets with the lowest recurrence rates at least 1% or something, but keep radius constant otherwise
#embed dim, false nearest BEFORE it drops

#use these parameters
m_delay<-max(delay_parameters)
m_dim<-max(dimensions)


recurrence<- NULL
determinism<- NULL
no_lines<- NULL
max_line<- NULL
avg_length_line<- NULL
shannon_entropy<- NULL
normalised_entr<- NULL
lam<- NULL
tt<- NULL

crqa_results_ab<-NULL


for (i in 1:length(mydata)){
  disp(i)
crqa_results_ab <- crqa(ts1 = mydata[,i], ts2 = mydata[,i+1], delay = m_delay, 
                        embed = m_dim, rescale = 2, radius = 5, normalize = 2, 
                        mindiagline = 2, minvertline = 2, tw = 0, whiteline = FALSE,
                        recpt = FALSE, side = "both") # running crqa, normalize = 2 z-score
i = i+2

recurrence[i]<-crqa_results_ab$RR #reccurence
determinism[i]<-crqa_results_ab$DET #determinism
no_lines[i]<-crqa_results_ab$NRLINE 
max_line[i]<-crqa_results_ab$maxL
avg_length_line[i]<- crqa_results_ab$L
shannon_entropy[i]<- crqa_results_ab$ENTR
normalised_entr[i]<-crqa_results_ab$rENTR
lam[i]<-crqa_results_ab$LAM
tt[i]<-crqa_results_ab$TT

#image(crqa_results_ab$RP) # cross-recurrence plot print(crqa_results_ab[1:9]) # crqa results

RP <- crqa_results_ab$RP # store cross-recurrence plot in variable RP 
# rotate matrix by 90◦ and plot - conventional representation
image(t(RP[, ncol(RP) : 1])) 

#to produce individual plot comments this out

png(file = paste(names(ID)[i],".png",sep = ""))
plot_CRQA<-image(t(RP[, ncol(RP) : 1])) 
#print(plot_CRQA)
dev.off()
}

summary_CRQA<-cbind(ID,recurrence,determinism,no_lines,max_lineavg_length_line,shannon_entropy,normalised_entr,
                    lam,tt)

