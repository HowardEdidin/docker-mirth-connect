import java.io.IOException;
import java.io.InputStream;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.OutputStream;
import java.io.File;
import java.util.Properties;

public class set_props {

    private static Properties props = new Properties();
    private static String propertiesFile = new String();

    public static boolean loadConfig() {
        try(InputStream in = new FileInputStream(propertiesFile)) {
            props.load(in);
        }
        catch (Exception e) {
            System.out.println(e.getMessage());
            return false;
        }

        return true;
    }

    private static boolean saveConfig() {
        try(OutputStream os = new FileOutputStream(propertiesFile)) {
            props.store(os, null);
        } catch (Exception e) {
            System.out.println(e.getMessage());
            return false;
        }
        
        return true;
    }

    private static void setProperty(String key, String value) {
        props.setProperty(key, value);
    }

    private static void configDatabaseProps() {
        setProperty("database.password", 
            System.getenv("MIRTH_DATABASE_PASSWORD"));
        setProperty("database.username", 
            System.getenv("MIRTH_DATABASE_USERNAME"));
        setProperty("database.url", 
            System.getenv("MIRTH_DATABASE_URL"));
        setProperty("database", 
            System.getenv("MIRTH_DATABASE"));
    }

    public static void main(String[] args) {
        propertiesFile = args[0];

        if(args.length == 0 ||  !(new File(propertiesFile).exists())) {
            System.out.println("No such file " + propertiesFile + 
            " or none was provided...");            
            return;
        }

        loadConfig();
        configDatabaseProps();
        saveConfig();
    }
}