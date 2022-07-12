# A Catalog Record&#39;s XML Reference

## Summary

The template for displaying a catalog record&#39;s XML document uses two different sources: the record&#39;s SOLR document, which is created by indexing and parsing the response for that item&#39;s OAI record from Alma, and the data retrieved from a call to Alma&#39;s Real-Time Availability API. The information from the OAI is processed whenever a manual indexing is performed or picked up after changes to the Alma record have been committed by one of the four daily automatic, incremental indexings. The values taken from the Real-Time API call are processed the moment the record is requested for viewing (XML or HTML.)

## Breakdown of XML Values&#39; Origins

- &quot;title&quot;: A value stored in the record&#39;s SOLR document, which originates from the Alma&#39;s OAI field of &quot;245&quot; and is formed by combining that datafield&#39;s subfield strings from &quot;a&quot;, &quot;b&quot;, &quot;f&quot;, &quot;g&quot;, &quot;k&quot;, &quot;n&quot;, &quot;p&quot;, and &quot;s&quot;, and stripping away the end punctuation.
- &quot;author&quot;: The first author stored in the record&#39;s SOLR document derived from either of the following combinations of datafields/subfields (and stripping away the end punctuation):
  - Datafield &quot;100&quot; and subfields &quot;a&quot;, &quot;b&quot;, &quot;c&quot;, &quot;d&quot;, &quot;g&quot;, &quot;q&quot;, and &quot;e&quot;, in that order.
  - Datafield &quot;110&quot; and subfields &quot;a&quot;, &quot;b&quot;, &quot;c&quot;, &quot;d&quot;, &quot;g&quot;, &quot;n&quot;, and &quot;e&quot;, in that order.
  - Datafield &quot;111&quot; and subfields &quot;a&quot;, &quot;c&quot;, &quot;d&quot;, &quot;e&quot;, &quot;g&quot;, &quot;j&quot;, &quot;n&quot;, &quot;q&quot;, and &quot;j&quot;, in that order.
- &quot;is\_physical\_holding&quot;: Another value pulled from the SOLR document. This value is set to &quot;true&quot; by the following logic:
  - An OAI field of &quot;997&quot; with the subfield of &quot;b&quot; is present, OR
  - The above field isn&#39;t present, and neither are &quot;998&quot; with the subfield &quot;c&quot; containing the string of &quot;available&quot; (down cased) or &quot;856&quot; with a field indicator 2 of &quot;0&quot;, &quot;1&quot;, or not &quot;2&quot; and subfields &quot;z&quot; or &quot;3&quot; that do not contain the strings &quot;abstract&quot;, &quot;description&quot;, &quot;sample text&quot;, or &quot;table of contents&quot;, AND the record&#39;s leader field, seventh position, contains either &quot;e&quot;, &quot;f&quot;, &quot;g&quot;, &quot;k&quot;, &quot;o&quot;, or &quot;r&quot;, as well as &quot;008&quot;&#39;s value at the thirtieth position not equaling &quot;o&quot; or &quot;s&quot;, OR the record&#39;s leader field, seventh position, not containing either &quot;e&quot;, &quot;f&quot;, &quot;g&quot;, &quot;k&quot;, &quot;o&quot;, or &quot;r&quot; and the twenty-fourth position of &quot;008&quot; not containing &quot;o&quot; or &quot;s&quot;.
- &quot;is\_electronic\_holding: Pulled from the SOLR document, this is set to &quot;true&quot; by the logic below:
  - The datafield &quot;998&quot; with the subfield &quot;c&quot; containing the string of &quot;available&quot; (down cased) or &quot;856&quot; with a field indicator 2 of &quot;0&quot;, &quot;1&quot;, or not &quot;2&quot; and subfields &quot;z&quot; or &quot;3&quot; that do not contain the strings &quot;abstract&quot;, &quot;description&quot;, &quot;sample text&quot;, or &quot;table of contents&quot;, OR
  - The above field isn&#39;t present, and neither is &quot;997&quot; with the subfield of &quot;b&quot; AND the record&#39;s leader field, seventh position, contains either &quot;e&quot;, &quot;f&quot;, &quot;g&quot;, &quot;k&quot;, &quot;o&quot;, or &quot;r&quot; and &quot;008&quot;&#39;s value at the thirtieth position equaling &quot;o&quot; or &quot;s&quot; OR the record&#39;s leader field, seventh position, not containing either &quot;e&quot;, &quot;f&quot;, &quot;g&quot;, &quot;k&quot;, &quot;o&quot;, or &quot;r&quot; and the twenty-fourth position of &quot;008&quot; containing &quot;o&quot; or &quot;s&quot;.
- &quot;edition&quot;: The first value taken from the SOLR document fed by extracting values from OAI datafields &quot;250&quot;, subfield &quot;a&quot; or &quot;254&quot;, subfield &quot;a&quot;.
- &quot;physical\_description&quot;: A SOLR document value processed from scraping the values of OAI datafield &quot;300&quot;, subfields &quot;a&quot;, &quot;b&quot;, &quot;c&quot;, &quot;e&quot;, and &quot;f&quot;.
- &quot;publisher&quot;: This SOLR document value is pulled by presenting the very first item that exists in the fields below, ordered by priority:
  - Datafield &quot;264&quot;, subfield &quot;b&quot;
  - Datafield &quot;260&quot;, subfield &quot;b&quot;
  - Datafield &quot;502&quot;, subfield &quot;c&quot;
- &quot;publication\_date&quot;: This is, once again, a value taken from the SOLR document for the record. The customized logic used to pull this value is quite extensive and could warrant a document this size just to explain the processing used to extract this data. Below are summary points for this value:
  - This displays only the starting year of publication, taken from datafield &quot;008&quot;, pulling a four-digit value from positions eight through eleven.
  - If the value derived from the positions above proves to be out of the range of what is deemed acceptable by Product Owners, the extraction defaults to the logic provided by our extraction tool, which is based off MARC Standards.
- &quot;isbn&quot;: SOLR document value generated by pulling the value from the OAI record&#39;s &quot;020&quot; datafield, subfield &quot;a&quot;. It goes through standardization provided by our extraction tool, which always returns the thirteen-digit code if it&#39;s available.
- &quot;issn&quot;: A value that lives in the SOLR document that is pulled from the first OAI field listed below that produces a result:
  - &quot;022&quot;, subfield &quot;a&quot;
  - &quot;022&quot;, subfield &quot;y&quot;
  - &quot;800&quot;, subfield &quot;x&quot;
  - &quot;810&quot;, subfield &quot;x&quot;
  - &quot;811&quot;, subfield &quot;x&quot;
  - &quot;830&quot;, subfield &quot;x&quot;
- &quot;supplemental\_links&quot;: This is still derived from the SOLR document. In this case, multiple values stored will display separately as elements wrapped in &quot;supplemental\_link&quot;.
  - These values are pulled from the OAI datafield &quot;856&quot; that only have a field indicator 2 value that is either blank, &quot;0&quot;, &quot;1&quot;, or &quot;2&quot;, and contains a path string in subfield &quot;u&quot;.
  - That mentioned subfield &quot;u&quot; feeds the XML &quot;link&quot; element.
  - The &quot;label&quot; element is derived from the first available subfields of &quot;y&quot;, &quot;3&quot;, or &quot;z&quot;.
  - When the field indicator 2 equals either &quot;0&quot; or &quot;1&quot;, the value taken from that list of possible subfields above must not be nil or deviate from the list of approved labels (down cased): &quot;table of contents&quot;, &quot;table of contents only&quot;, &quot;publisher description&quot;, &quot;cover image&quot;, or &quot;contributor biographical information&quot;.
  - If the label value in the SOLR document is empty (which can happen when the field indicator 2 equals &quot;2&quot;), the path string is provided in the &quot;label&quot; element instead.
- &#39;physical\_holdings&quot;: This group of elements is processed from the Real-Time API provided by Alma.
  - A &quot;physical\_holding&quot; is produced for each &quot;holding&quot; with a positive number of &quot;items&quot; in the resulting API response.
    - &quot;call\_number&quot;: This is taken from the response&#39;s datafield &quot;AVA&quot;, subfield &quot;d&quot;.
    - &quot;items&quot;: a grouping element that contains all the holding&#39;s Items.
      - &quot;item&quot;
        - &quot;library&quot;: This depends on whether the item&#39;s &quot;in\_temp\_location&quot; field is populated with &quot;true&quot;.
          - If it is, the value will be taken from the item&#39;s &quot;temp\_library&quot; field.
          - Else, it will populate the &quot;AVA&quot;, subfield &quot;b&quot; value.
        - &quot;location&quot;: This also depends on whether the item&#39;s &quot;in\_temp\_location&quot; field is populated with &quot;true&quot;.
          - If yes, then this will return the value in &quot;temp\_location&quot; of the item.
          - Else, &quot;AVA&quot;, subfield &quot;j&quot;.
        - &quot;barcode&quot;: filled by the &quot;item\_data&quot;/&quot;barcode&quot; field.
        - &quot;volume\_or\_issue&quot;: parsed from the &quot;item\_data&quot;/&quot;description&quot; inner text.
        - &quot;status&quot;: pulled from &quot;item\_data&quot;/&quot;base\_status&quot;.