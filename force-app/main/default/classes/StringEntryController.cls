public class StringEntryController {
 public String stringVal {get; set;}
 public String[] chosenVals {get; 
                         set {
                                stringVal='';
                                for (String val : value)
                                {
                                 stringVal+=':' + val;
                                }
                            
                             stringVal=stringVal.substring(1);
                             ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, ' Set string val to ' + stringVal));
                             }
                         }
  
  
}