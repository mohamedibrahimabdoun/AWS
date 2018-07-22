import sys,json;

tagvalue=sys.argv[3]
jsonresult=sys.argv[2]
rootelement=sys.argv[1]

with open('result.json') as json_data:
    d = json.load(json_data)
    for item in d[rootelement]: 
       if "Tags" in item:
         for i in item["Tags"]:
           if i["Value"]==tagvalue:
             sys.stdout.write(item[jsonresult])
        
	  
