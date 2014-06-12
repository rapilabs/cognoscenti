package com.fujitsu.gwt.bewebapp.server;

import java.io.*;
import java.util.Scanner;

/**
 Read and write a file using an explicit encoding.
 Removing the encoding from this code will simply cause the
 system's default encoding to be used instead.
*/
public final class FileReader {

  /** Requires two arguments - the file name, and the encoding to use.  */
  public static void main(String... aArgs) throws IOException {
    String fileName = aArgs[0];
    String encoding = aArgs[1];
    FileReader test = new FileReader(
      fileName, encoding
    );
    test.write("hello");
    test.read();
  }

  /** Constructor. */
  FileReader(String aFileName, String aEncoding){
    fEncoding = aEncoding;
    fFileName = aFileName;
  }

  /** Write fixed content to the given file. */
  void write(String data) throws IOException  {
    log("Writing to file named " + fFileName + ". Encoding: " + fEncoding);
    Writer out = new OutputStreamWriter(new FileOutputStream(fFileName), fEncoding);
    try {
      out.write(data);
    }
    finally {
      out.close();
    }
  }

  /** Read the contents of the given file. */
  String read() throws IOException {
    log("Reading from file.");
    StringBuilder text = new StringBuilder();
    String NL = System.getProperty("line.separator");
    Scanner scanner = new Scanner(new File(fFileName), fEncoding);
    try {
      while (scanner.hasNextLine()){
        text.append(scanner.nextLine() + NL);
      }
    }
    finally{
      scanner.close();
    }
    return text.toString();
  }

  // PRIVATE
  private final String fFileName;
  private final String fEncoding;
  private final String FIXED_TEXT = "But soft! what code in yonder program breaks?";

  private void log(String aMessage){
    //System.out.println(aMessage);
  }
}

