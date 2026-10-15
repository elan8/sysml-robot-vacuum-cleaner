package Doc42 {
    doc /* The Doc42 document composition library (design §3.5).
         * Ships inside the doc42 binary; `doc42 library export` writes it out for editors. */

    private import ScalarValues::String;

    metadata def Document {
        doc /* Marks a view usage as a Doc42 document. Its nested views are the document's
             * sections, in authored order. */
        attribute title : String;
        attribute subtitle : String [0..1];
        attribute organization : String [0..1];
        attribute number : String [0..1];
        attribute revision : String [0..1];
        attribute status : String [0..1];
        attribute template : String [0..1];
    }

    metadata def Section {
        doc /* Presentation data for a section (a view nested in a document view). Without it,
             * the section's title is the view's declared name as written. */
        attribute title : String;
    }

    metadata def Prose {
        doc /* Includes a Markdown file as prose of the annotated section, after its `doc`
             * comments. The path is relative to the file containing the annotation and must stay
             * inside the workspace. */
        attribute file : String;
    }

    metadata def Figure {
        doc /* Includes an authored SVG drawing as a figure of the annotated section, after its
             * prose. The path is relative to the file containing the annotation and must stay
             * inside the workspace. An authored figure is not checked against the model. */
        attribute file : String;
        attribute caption : String [0..1];
    }

    metadata def Table {
        doc /* Presents the elements the annotated section exposes as a table, one row for each
             * element. `columns` lists the columns, separated by commas, each as `Title = content`
             * or as the content alone. The content is one of:
             *
             *   id, name, qualified-name, kind, text, type, owner
             *   satisfied-by, verified-by, derived-from, derives   (for a requirement)
             *   verifies                                           (for a verification case)
             *   original, derived                                  (for a derivation connection)
             *   .feature or .feature.feature   the value of a feature of the element
             *   @Metadata.feature              a value of a metadata annotation of the element
             *   relation / content             the content for each element a relation names,
             *                                  e.g. `verified-by / @VerificationMethod.kind`
             *
             * `kind` keeps only elements of that kind (`"requirement"`, `"part"`,
             * `"connection"`, `"part def"`, ...). `sort` names the content to order the rows by;
             * without it, rows are in the order the elements are written in the model. */
        attribute columns : String;
        attribute kind : String [0..1];
        attribute sort : String [0..1];
        attribute caption : String [0..1];
    }

    metadata def RequirementTable {
        doc /* Presents the requirements the annotated section exposes as a table: identifier,
             * name, text, and the elements satisfying each requirement. Temporary: once Spec42
             * models `render` (elan8/spec42#209), this becomes `render asRequirementTable`. */
    }
}
