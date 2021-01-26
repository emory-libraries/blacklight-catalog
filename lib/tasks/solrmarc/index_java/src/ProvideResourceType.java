import org.solrmarc.index.SolrIndexer;
import java.util.Set;
import java.util.LinkedHashSet;
import org.marc4j.marc.Record;

public class ProvideResourceType{
    Set<String> result = new LinkedHashSet<String>();
    Set<String> physical = new LinkedHashSet<String>(); 
    SolrIndexer.addSubfieldDataToSet(record, physical, "997");
    Set<String> electronic = new LinkedHashSet<String>(); 
    SolrIndexer.addSubfieldDataToSet(record, electronic, "998");

    if(!physical.isEmpty())
    {
        result.add("Physical Resource");
    }

    if(!electronic.isEmpty())
    {
        result.add("Electronic Resource");
    }

    return result;
}