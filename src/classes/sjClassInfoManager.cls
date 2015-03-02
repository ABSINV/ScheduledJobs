/* 
*  Class containing methods to get info about a class
*/
public class sjClassInfoManager 
{
    //Method will return the system type, if it exists for the given string
    public static System.Type GetTypeForClassName(String name) 
    {
        System.Type t;
        
        //Get the system type for the given string
        t = System.Type.forName(name);
        
        //If the system type is null and the string doesn't contain a dot. No dot means no namespace was specified
        if ((t == null) && (!name.contains('.'))) 
        {
            t = System.Type.forName(null,name);
        }    
        
        //If the system type is still null and the string contains a dot, try to get the system type for the string without the namespace
        if ((t == null) && (name.indexOf('.')!=-1))
        {
            String sansNamespace = name.substring(name.indexOf('.') + 1);
            t = System.Type.forName(sansNamespace);
        } 
        return t;
    }
}