# -*- coding: utf-8 -*-
import numpy as np
from glob import glob
import math
import matplotlib.pyplot as plt
from collections import defaultdict
from collections import OrderedDict
from collections import namedtuple
import pickle
import re
import os.path
from scipy import stats


# used for label sorting
#import operator
 

# Configuration:
#-----------------




# PATHS to look for .jtl files
 
PATHS_API =   ["/Users/chrig/benchmark-results/v3_api/"]       
PATHS_BURST = ["/Users/chrig/benchmark-results/v3_api_burst/"]
PATHS_NON_BURST = ["/Users/chrig/benchmark-results/v3_api_non_burst/"]    
PATHS_GOOGLE = ["/Users/chrig/benchmark-results/v3_api_google/"]

PATHS = PATHS_API+PATHS_BURST+PATHS_NON_BURST+PATHS_GOOGLE
#PATHS = PATHS_API+PATHS_BURST+PATHS_GOOGLE
#PATHS = PATHS_API+PATHS_BURST+PATHS_NON_BURST
#PATHS = PATHS_GOOGLE
#PATHS = PATHS_NON_BURST
#PATHS = PATHS_BURST

PATHS =   ["/Users/chrig/benchmark-results/predict_burst_aws/"] 
 
# Keys for grouping or selecting single instances
KEYS_GOOGLE = ["g1_g1", "s1_s1","s2_s1","s4_s1", "h2_s1", "h2_h2", "h4_s1"]
KEYS_AWS = ["c4l_s","c4l_m3m","m4l_s","m4l_m3m","c4xl_s","c4xl_m","m4xl_s"]
KEYS_BURST = ["mi_mi_burst", "s_mi_burst", "s_s_burst", "m_mi_burst" ,"m_s_burst"]
KEYS_NON_BURST = ["mi_mi", "s_mi","m_mi"]
KEYS_CONFIG_BURST = ["s_mi_burst", "s_s_burst"]+["m_mi_burst", "m_s_burst"]
KEYS_CONFIG_NON_BIRST = ["c4l_s","c4l_m3m","m4l_s","m4l_m3m"]
KEYS_BURST_NON_BURST = ["mi_mi_burst", "mi_mi", "s_mi_burst","s_mi", "m_mi_burst","m_mi"]


KEYS = KEYS_BURST+KEYS_NON_BURST+KEYS_AWS+KEYS_GOOGLE


#KEYS = KEYS_CONFIG_NON_BIRST
#KEYS = KEYS_CONFIG_BURST
#KEYS = KEYS_BURST_NON_BURST
#KEYS = KEYS_GOOGLE
#KEYS = KEYS_BURST
#KEYS = KEYS_BURST+KEYS_AWS+KEYS_GOOGLE

#KEYS = KEYS_NON_BURST
#KEYS= ["m_mi"]

#KEYS= ["322"]

FIG_NAME = "predict_burst_aws"
FIG_WIDTH = 10
FIG_HEIGHT = 7.5
ERROR_EVERY = 20
#enable data_file_overwrite
OVERWRITE_DATA_FILE = False
#Print results
PLOT_LINES = True
PLOT_SINGLE = True
PLOT_AVERAGE = False

AVERGAE_INDICATOR = False
SINGLE_INDICATOR = False

PLOT_BOXPLOT = True
ENABLE_FILE_INFO = False


SAMPLE_LENGTH = 120
PADDING = 0
GAP_LENGTH = 30

WILCOXONU = False
DROP_TIME = False

PRINT_LENGTH = 300
PRINT_START = 100



# What to compute: 1 = started reqeuest, 2 = finished, else = open requests
MODE = 2

class BenchmarkInstance(object):
    def __init__(self,filename,rps,metrics):
        self.filename = filename
        self.rps = rps
        self.metrics = metrics

class AverageInstance(object):
    def __init__(self, itk,averages,list_with_means, list_with_medians,mean_mean,mean_mean_std,mean_median,mean_median_std,median_req95,median_req99, count,metrics,mean_rsd):
        self.itk = itk
        self.averages = averages
        self.list_with_means = list_with_means 
        self.list_with_medians = list_with_medians
        self.mean_mean = mean_mean
        self.mean_mean_std = mean_mean_std
        self.mean_median = mean_median
        self.mean_median_std = mean_median_std
        self.median_req95=median_req95
        self.median_req99=median_req99
        self.count = count
        self.metrics = metrics
        self.mean_rsd = mean_rsd

class Filename:
    def __init__(self, filename):
        self.filename = filename
        self.splits = self.filename.split("-")
        self.j_exid = self.splits[0][2:]
        self.benchmark = '-'.join(self.splits[1].split("_")[1:-1])
        self.types_short = self.splits[3]
        self.types_long = self.splits[4]
        self.number_of_slaves = self.get_flag('-j')
        self.execution_time = self.get_flag('-dur')
        self.ramp_up_time = self.get_flag('-rt')
        self.number_of_threads = self.get_flag('-thr')
        self.iteration_count = self.get_flag('-iter')
        self.timestamp = self.get_flag('-tst')
        self.os = self.get_flag('-os')
        
    def get_flag(self,flag):
        pattern = '(?<={})[a-zA-Z0-9]*'.format(flag)
        tmp =  re.search(pattern, self.filename)
        if tmp:
            return tmp.group(0)
            
        else:
            return "pattern not found"
#-------Methods----------

def save_object(obj, filename):
    with open(filename, 'wb') as output:
        pickle.dump(obj, output, pickle.HIGHEST_PROTOCOL)
        
def load_object(filename):
    with open(filename, 'rb') as input:
        return pickle.load(input)
        
def compute_started_requests_per_second(data):
    rps = defaultdict(list)
    for request in data:
        if request["success"] == True:
            s = math.ceil(request["timeStamp"])
            rps[s].append(1)      
    for key, value in rps.items():
        rps[key] = len(value)
    return OrderedDict(sorted(rps.items()))

def compute_finished_requests_per_second(data):
    rps = defaultdict(list)
    for request in data:
        if request["success"] == True:
            s = math.ceil(request["timeStamp"]+(request["elapsed"]/1000)) 
            rps[s].append(request)      
    for key, value in rps.items():
        rps[key] = len(value)
    return OrderedDict(sorted(rps.items()))
    
def compute_open_requests_per_second(data):
    started_requests = defaultdict(list)
    finished_requests = defaultdict(list)

    for request in data:
        if(request["success"]) == True:
            s = math.ceil(request["timeStamp"])
            started_requests[s].append(request)
            f = math.ceil(request["timeStamp"]+(request["elapsed"]/1000)) 
            finished_requests[f].append(request)

    for skey, svalue in started_requests.items():
        started_requests[skey] = len(svalue)

    for fkey, fvalue in finished_requests.items():
        finished_requests[fkey] = len(fvalue)
        
    open_requests_per_second =  defaultdict(list)
    last_count = 0
    for j in range(sorted(list(finished_requests.keys()))[-1]):
        current_count = last_count+(started_requests.get(j,0) - finished_requests.get(j,0))
        open_requests_per_second[j] = current_count
        last_count = current_count
    
    return OrderedDict(sorted(open_requests_per_second.items()))

def remove_path_from_file(file):
    removed_path = file
    for p in PATHS:
        tmp = file.replace(p[:-1], "")
        if tmp != file:
            removed_path = tmp[1:]
    return removed_path

    
def get_name(file):
#    j_exid435-morphia_distributed_api_NoSlaves_debian-s1_s1-n1_standard_1_n1_standard_1-j0-t2500-s600-rt0_0_2016-07-25_07-21-34
    n = Filename(remove_path_from_file(file))
    return "{} {} {}".format(n.j_exid, n.benchmark ,n.types_short)

def get_uid(filename):
    try:
        found = re.search('j_(.+?)-', filename).group(1)
        return found
    except AttributeError:
        print("No id found for: %s"%(filename))
    
def compute_sample_metrics(data_dict):

    sample_length = SAMPLE_LENGTH-PADDING
    drop_time = 0
    last_request = 0
    nongap_duration = 0
    sample_size_reached = False
    drops = []
        
    for time, count in data_dict.items():
        if time == last_request+1:
            nongap_duration = nongap_duration+1
            last_request = time
            if nongap_duration >= sample_length:
                sample_size_reached = True
        else:
            #after a gap
            if sample_size_reached:
                drop_time = last_request
                drops.append(last_request)
            if last_request + GAP_LENGTH <= time:
                nongap_duration = 0
                sample_size_reached = False
            last_request = time
            
    if sample_size_reached == True:
        drop_time = last_request
      
    if drop_time == 0:
        drop_time = last_request
#        print("Attention: includes gaps! Set to end:{}".format(last_request))
        raise Exception("No GAP-free part found!")
   
    print(drops)
    values = list(data_dict.values())
    dict_keys = list(data_dict.keys())
    
    #adjusting
    if PADDING and drop_time-PADDING in dict_keys:
        drop_time_index = dict_keys.index(drop_time-PADDING)
        drop_time = drop_time-PADDING
    else:
        print("droptime: {}".format(drop_time))
        drop_time_index =  dict_keys.index(drop_time)
        while dict_keys[drop_time_index] >= drop_time-PADDING:
            drop_time_index =  drop_time_index-1
            print("finding next smaller:{}>{}".format(dict_keys[drop_time_index],drop_time-PADDING))
        drop_time = dict_keys[drop_time_index]

    if DROP_TIME and DROP_TIME<dict_keys[-1]:
        drop_time = DROP_TIME
        drop_time_index = dict_keys.index(drop_time)

    mean = np.mean(values[drop_time_index-sample_length:drop_time_index])
    median = np.median(values[drop_time_index-sample_length:drop_time_index])
    std = np.std(values[drop_time_index-sample_length:drop_time_index]) 
    rsd = 100*(std/mean)
    
    return sample_metric(mean, median, std, drop_time, sample_length,rsd)

def print_sample_indicator(requests_dict, metric,drop_time,sample_length):
    keys = list(requests_dict.keys())
    index_drop_time = keys.index(drop_time)
    ax.plot(keys[index_drop_time-sample_length:index_drop_time], [metric for i in range(sample_length)],'k.',markersize=6) 

def print_sample(filename, requests_dict):
    label = get_label_for_key(filename.split(" ")[2])
    
    ax.plot(list(requests_dict.keys())[PRINT_START:], list(requests_dict.values())[PRINT_START:],'-',markersize=6,label=label) 

def print_averages(itk, averages):
    label = "mean: {}".format(itk)
    keys = list(averages.keys())
    values = [i[0] for i in list(averages.values())]
    ax.plot(keys, values,'-',markersize=6,label=label)

def print_line_with_error_indicators(itk, averages):
    label = "mean: {}".format(get_label_for_key(itk))
    errorevery = ERROR_EVERY
    keys = list(averages.keys())
    values = [i[0] for i in list(averages.values())]
    lowers = [i[1] for i in list(averages.values())]
    uppers = [i[2] for i in list(averages.values())]
    ax.errorbar(keys, values, yerr=[lowers, uppers],errorevery=errorevery, ecolor='k',capthick=2, label=label)
        
def print_stats_single(benchmark_instance):
    print("name: %s"%(benchmark_instance.filename))
    print("mean: %f"%(benchmark_instance.mean))
    print("median: %f"%(benchmark_instance.median))
    print("standard-deviation: %f"%(benchmark_instance.std))
    print("------------------")  

def get_instance_type_key(file):
    filename = remove_path_from_file(file)
    tmp_itk = None
    for itk in KEYS: 
        if filename.find(itk) > -1:
            tmp_itk = itk
            break
    return tmp_itk
    
def get_data_file_path_name(file):
    uid = get_uid(file)
    return ".data/{}.pkl".format(uid)
    # for more complex datafile names
    #    instance_type_key = get_instance_type_key(file)
    #    return ".data/{}_{}.pkl".format(uid, instance_type_key)
    
def get_label_for_key(key):
    if key == "mi_mi":
        return "A_nb1m"
    elif key == "mi_mi_burst":
        return "A_b1m"
    elif key == "s_mi":
        return "A_nb1s"
    elif key == "s_mi_burst":
        return "A_b1s_1"
    elif key == "s_s_burst":
        return "A_b1s_2"
    elif key == "m_mi":
        return "A_nb2"
    elif key == "m_mi_burst":
        return "A_b2_1"
    elif key == "m_s_burst":
        return "A_b2_2"
    elif key == "m4l_s":
        return "A_gp2_1"
    elif key == "m4l_m3m":
        return "A_gp2_2"
    elif key == "m4xl_s":
        return "A_gp4"
    elif key == "c4l_s":
        return "A_co2_1"
    elif key == "c4l_m3m":
        return "A_co2_2"
    elif key == "c4xl_s":
        return "A_co4"
#google
    elif key == "g1_g1":
        return "G_b1"
    elif key == "s1_s1":
        return "G_gp1"
    elif key == "s2_s1":
        return "G_gp2"
    elif key == "s4_s1":
        return "G_gp4"
#    elif key == "h2_s1":
#        return "G_co2_1"
    elif key == "h2_h2":
        return "G_co2"
    elif key == "h4_s1":
        return "G_co4"
    else:
        print ("no label found for key:{}".format(key))
        return key
    
sample_metric = namedtuple('SampleMetric','mean, median, std, drop_time, sample_length, rsd')
config = namedtuple('SampleMetric','KEYS SAMPLE_LENGTH PADDING GAP_LENGTH WILCOXONU DROP_TIME PRINT_LENGTH FIG_NAME')
#---init script -----------------------------------------------------------------------------------------------------
#NON_BURSTING_CONFIG = config(["c4l_s","c4l_m3m","m4l_s","m4l_m3m"],240, 0,100,True,False,360,"deployment_options_non_bursting")                        
#BURSTING_CONFIG = config(["s_mi_burst", "s_s_burst", "m_mi_burst", "m_s_burst"],150,0,100,True, False,250,"deployment_options_bursting")
#
#config = BURSTING_CONFIG
#KEYS=config.KEYS
#SAMPLE_LENGTH = config.SAMPLE_LENGTH
#PADDING = config.PADDING
#GAP_LENGTH = config.GAP_LENGTH
#WILCOXONU = config.WILCOXONU
#DROP_TIME = config.DROP_TIME
#PRINT_LENGTH = config.PRINT_LENGTH
#FIG_NAME = config.FIG_NAME

#---init script -----------------------------------------------------------------------------------------------------
files = []
for path in PATHS:
        files.extend(glob(path+'*.jtl'))

for idx,file in enumerate(files):

    # check if there is a key in the filename
    instance_type_key = get_instance_type_key(file)
    if instance_type_key == None:
        print("No KEY found in filename and therefore ignored: %s"%(file))
        continue
    
    
    filename = get_name(file)
    if os.path.exists(get_data_file_path_name(file)) and not OVERWRITE_DATA_FILE:
        continue
    print("%s of %s: %s"%(idx+1, len(files),filename))
    # read the raw file
    data = np.genfromtxt(file, delimiter=',', skip_header=0, names=True, usecols=("timeStamp", "elapsed", "success"), dtype=[("timeStamp", float), ( "elapsed", float), ("success", bool)])
       
    #transform times from ms to s based on numpy array operations
    time_in_ms_from_start = data['timeStamp']-data['timeStamp'][0]
    time_in_s_from_start = time_in_ms_from_start/(1000)
    data['timeStamp'] = time_in_s_from_start 
    
    if MODE == 1:
        rps = compute_started_requests_per_second(data)
    elif MODE == 2:
        rps= compute_finished_requests_per_second(data)
    else:
        rps = compute_open_requests_per_second(data)
    
    benchmark_instance = BenchmarkInstance(filename,rps, None)
    
    save_object(benchmark_instance,get_data_file_path_name(file))
    del(benchmark_instance)

benchmarks_per_type = defaultdict(list)
for idx,file in enumerate(files):
    if ENABLE_FILE_INFO:
        print("Check File %s of %s"%(idx+1, len(files)))
    instance_type_key = get_instance_type_key(file)
    if instance_type_key in KEYS:
        benchmark_instance = load_object(get_data_file_path_name(file))
        print("Load File %s"%(benchmark_instance.filename))
        
        if PRINT_LENGTH and max(list(benchmark_instance.rps.keys()))>PRINT_LENGTH:
            benchmark_instance.rps = {k:v for k,v in benchmark_instance.rps.items() if k < PRINT_LENGTH}        
        
        if DROP_TIME and DROP_TIME not in benchmark_instance.rps.keys():
            print("{} exluded!".format(benchmark_instance.filename))
            continue
        
        sample_metrics = compute_sample_metrics(benchmark_instance.rps)
        benchmark_instance.metrics = sample_metrics
        benchmark_instance.mean = sample_metrics.mean
        benchmark_instance.median = sample_metrics.median
        benchmark_instance.std = sample_metrics.std
        benchmark_instance.drop_time = sample_metrics.drop_time
        benchmark_instance.sample_length =  sample_metrics.sample_length

        benchmarks_per_type[instance_type_key].append(benchmark_instance)
        
averages_per_type = {}
for itk, benchmarks in benchmarks_per_type.items():
#    print(itk)
    aggregated_counts = defaultdict(list)
    #collect for every second the count form each individual benchmark
    
    list_with_means = []
    list_with_medians = []
    list_with_rsds = []
    for benchmark in benchmarks:
        list_with_means.append(benchmark.mean)
        list_with_medians.append(benchmark.median)
        list_with_rsds.append(benchmark.metrics.rsd)
        for timestamp, count in benchmark.rps.items():
            aggregated_counts[timestamp].append(count)
      
    averages = defaultdict(list)
    for i in range(max(list(aggregated_counts.keys()))+1):#we read the biggest number and take it as index, therefore +1
        if len(aggregated_counts[i]) > 0:
            item_mean = np.mean(aggregated_counts[i])
            item_lower_error= item_mean-np.percentile(aggregated_counts[i],25)
            item_upper_error = np.percentile(aggregated_counts[i],75)-item_mean
            averages[i] = [item_mean,item_lower_error,item_upper_error]

    only_averages = defaultdict(int)
    for key, value in averages.items():
        only_averages[key] = value[0]

    mean_rsd = np.mean(list_with_rsds)
#    mean_mean = np.mean(list_with_means)
#    mean_mean_std =  np.std(list_with_means)
#    mean_median = np.mean(list_with_medians)
#    mean_median_std = np.std(list_with_medians, ddof=1)
    
    metrics = compute_sample_metrics(only_averages)
    median = metrics.median
    median_std = metrics.std
    mean = metrics.mean
    mean_std = metrics.std
    
    median_req95 = ((1.96*mean_std)/(mean*0.05))**2
    median_req99 = ((2.576*mean_std)/(mean*0.05))**2
    count = len(benchmarks)

    #round tp next int
    median_req95 = math.ceil(median_req95)
    median_req99 = math.ceil(median_req99)
    
    averages_per_type[itk] = AverageInstance(itk,averages,list_with_means, list_with_medians,mean,mean_std,median,median_std,median_req95,median_req99, count,metrics, mean_rsd)
    
    
    
print("=== SINGLE ===")        
for itk, benchmarks in  sorted(benchmarks_per_type.items(), key=lambda tup: tup[0]):
    for benchmark in benchmarks:
        print_stats_single(benchmark)

print("=== TYPES ===")
file_stats = open("{}_stats.csv".format(FIG_NAME), "w")
file_stats.write("sample length: {}, padding: {},gap: {},nett lenngth: {}\n".format(SAMPLE_LENGTH, PADDING, GAP_LENGTH, SAMPLE_LENGTH-PADDING))
file_stats.write("Instance Type,Count,95%CL (5%MOE),99%CL (5%MOE),Mean,Median,Mean Std,RSD,Mean RSD\n")
for key in KEYS:
    if key in averages_per_type.keys():
        average_instance = averages_per_type[key]
        file_stats.write("{},{},{},{},{},{},{},{},{}\n".format(get_label_for_key(average_instance.itk),average_instance.count,average_instance.median_req95,average_instance.median_req99,average_instance.mean_mean,average_instance.mean_median,average_instance.mean_median_std,average_instance.metrics.rsd, average_instance.mean_rsd))
        print("---- {}----\ncount: {}\n95%CL (5%MOE):{}\n99%CL (5%MOE): {}\nmedian: {}\nstd: {}".format(average_instance.itk,average_instance.count,average_instance.median_req95,average_instance.median_req99,average_instance.mean_median,average_instance.mean_median_std))
file_stats.close()

if WILCOXONU:
    file_wilcoxon = open("{}_wilcoxon.csv".format(FIG_NAME), "w")
    file_wilcoxon.write("c1,count_c1,mean1,std1 ,c2, count_c2,mean_c2,std_c2,p-Value, U-value\n ")
    print("Webapp-DB, Webapp-DB, p-Value, U-value")
    temp = KEYS.copy()
    for key in KEYS:
        temp.remove(key)
        for temp_key in temp:
            wa1 = key.split("_")[0]
            db1 = key.split("_")[1]
            wa2 = temp_key.split("_")[0]
            db2 = temp_key.split("_")[1]

            key_mean = averages_per_type[key].mean_mean
            key_std = averages_per_type[key].mean_mean_std
            temp_mean = averages_per_type[temp_key].mean_mean
            temp_std = averages_per_type[temp_key].mean_mean_std
            
            wil = stats.mannwhitneyu(averages_per_type[key].list_with_means,averages_per_type[temp_key].list_with_means,alternative='two-sided')
            print("{}-{}, {}-{}, {}, {}".format(wa1, db1, wa2, db2,wil.pvalue, wil.statistic))
#            file_wilcoxon.write("{}, {}, {}, {}, {}\n".format(wa1, db1, wa2, db2,wil.pvalue))
            file_wilcoxon.write("{}, {},{},{},{},{},{}, {},{},{}\n".format(get_label_for_key(key),len(averages_per_type[key].list_with_means),key_mean,key_std, get_label_for_key(temp_key), len(averages_per_type[temp_key].list_with_means),temp_mean,temp_std,wil.pvalue, wil.statistic))  
    file_wilcoxon.close()
    
if PLOT_LINES:
    fig = plt.figure(figsize=(FIG_WIDTH, FIG_HEIGHT))
#    fig.suptitle('Request Count Evolution', fontsize=12, fontweight='bold')
    
    ax = fig.add_subplot(111)
    ax.set_xlabel('duration in seconds')
    ax.set_ylabel('successfull requests per second')
    
    if PLOT_SINGLE:            
        for itk, benchmarks in  sorted(benchmarks_per_type.items(), key=lambda tup: tup[0]):
            for benchmark in benchmarks:
                print_sample(benchmark.filename, benchmark.rps)
                if SINGLE_INDICATOR:
                    print_sample_indicator(benchmark.rps, benchmark.mean,benchmark.drop_time,benchmark.sample_length)           
    
    if PLOT_AVERAGE:            
        for itk, average_instance in sorted(averages_per_type.items(), key=lambda tup: tup[0]):            
#            print_averages(itk, average_instance.averages)
            print_line_with_error_indicators(itk, average_instance.averages)
            metrics = average_instance.metrics 
            if AVERGAE_INDICATOR:
                print_sample_indicator(average_instance.averages, metrics.mean,metrics.drop_time,metrics.sample_length)
    


    
        
    #Handles sorting for legend
    #handles, labels = ax.get_legend_handles_labels()
    #hl = sorted(zip(handles, labels),key=operator.itemgetter(1))
    #h, l = zip(*hl)
    #lgd = ax.legend(h, l, loc='upper center', bbox_to_anchor=(0.5,-0.1), ncol=2, markerscale=2, title="Files")
    handles, labels = ax.get_legend_handles_labels()
    lgd = ax.legend(handles, labels, loc='upper center', bbox_to_anchor=(0.5,-0.1), ncol=2, markerscale=2)#, title="Files")
    plt.grid()
    plt.savefig('{}_lines.eps'.format(FIG_NAME), bbox_extra_artists=(lgd,), bbox_inches='tight')


if PLOT_BOXPLOT:
    fig = plt.figure(figsize=(FIG_WIDTH, FIG_HEIGHT))
#    fig.suptitle('Request Rate Boxplot', fontsize=12, fontweight='bold')
    ax = fig.add_subplot(111)
    ax.set_xlabel('configuration')
    ax.set_ylabel('successfull requests per second')
    boxplot_data = []
    boxplot_labels = []
           
    for key in KEYS:
        if key in averages_per_type.keys():
            boxplot_data.append(averages_per_type[key].list_with_medians)
            label = get_label_for_key(key)+"\n{}".format(len(averages_per_type[key].list_with_medians))
            boxplot_labels.append(label)
           
    plt.boxplot(boxplot_data, labels=boxplot_labels)
    plt.savefig('{}_boxplot.eps'.format(FIG_NAME),bbox_inches='tight')

if PLOT_LINES or PLOT_BOXPLOT:
    plt.show
