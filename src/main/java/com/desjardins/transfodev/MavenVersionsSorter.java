package com.desjardins.transfodev;

import java.util.SortedSet;
import java.util.TreeSet;
import java.util.stream.Collectors;

import org.apache.commons.cli.CommandLine;
import org.apache.commons.cli.CommandLineParser;
import org.apache.commons.cli.DefaultParser;
import org.apache.commons.cli.HelpFormatter;
import org.apache.commons.cli.Options;
import org.apache.commons.cli.ParseException;
import org.apache.maven.artifact.versioning.ComparableVersion;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONStringer;

public class MavenVersionsSorter {

	public static void main(String[] args) {
		Options options = new Options();
		options.addRequiredOption("j", "json", true, "maven versions JSON array ex.: [\"version2\", \"version1\"].");
		options.addOption("h", "help", false, "Display usage.");
		
		CommandLineParser parser = new DefaultParser();
		CommandLine cmd = null;
		try {
			cmd = parser.parse( options, args);
		} catch (ParseException e) {
			showHelp(options);
			return;
		}
		
		if(cmd.hasOption('h')) {
			showHelp(options);
			return;
		} 
		
		if(cmd.hasOption('j')) {
			JSONArray jsonArray = new JSONArray();
			try {
				jsonArray = new JSONArray(cmd.getOptionValue('j'));
			} catch (JSONException e) {
				System.err.println("Invalid JSON.");
				showHelp(options);
				return;
			}

			SortedSet<ComparableVersion> sortedVersions = new TreeSet<>();
			
			jsonArray.forEach(version -> 
				sortedVersions.add(new ComparableVersion((String) version)));

			System.out.println(JSONStringer.valueToString(sortedVersions.stream()
					.map(ComparableVersion::toString)
					.collect(Collectors.toList())));
		}

		
	}

	private static void showHelp(Options options) {
		HelpFormatter formatter = new HelpFormatter();
		formatter.printHelp( "sort-maven-versions", options );
	}
}
