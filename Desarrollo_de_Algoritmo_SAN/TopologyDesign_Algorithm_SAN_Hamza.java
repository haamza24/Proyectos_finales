package Practica1;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.Random;
import java.util.Set;

import org.jgrapht.Graph;
import org.jgrapht.GraphPath;
import org.jgrapht.alg.connectivity.BiconnectivityInspector;
import org.jgrapht.alg.shortestpath.FloydWarshallShortestPaths;
import org.jgrapht.graph.DefaultUndirectedWeightedGraph;

import com.net2plan.interfaces.networkDesign.Demand;
import com.net2plan.interfaces.networkDesign.IAlgorithm;
import com.net2plan.interfaces.networkDesign.Link;
import com.net2plan.interfaces.networkDesign.Net2PlanException;
import com.net2plan.interfaces.networkDesign.NetPlan;
import com.net2plan.interfaces.networkDesign.Node;
import com.net2plan.utils.Triple;

//import Practica1.TopologyDesign_ExampleLocalSearch.DesignEvaluation;

/* See in this template recommendations for a well structured code:
 * 
 * NAMES OF CLASSES AND VARIABLES: 
 * 1) Java best practices mandate that classes start with capital letters (e.g. NodeLocation_TEMPLATE), while variable names start with lowercase letters.
 * 2) Variable and class names can be long. They are recommended to express in its name, exactly what they do, 
 * e.g. a name like 'numberOfAccessNodesConnectedToThisLocation' is preferred to 'n'.
 * 3) Use the so-called CAMEL CASE for the class and variable names: writing phrases such that each word or abbreviation in the middle of the 
 * phrase begins with a capital letter, with no intervening spaces or punctuation. E.g. numberOfAccessNodesConnectedToThisLocation. In Java it is less common 
 * to use underscore (e.g. number_of_access_nodes_connected_to_this_location is not within best practices in Java naming conventions) 
 * 4) It is in general accepted that global constants that are very heavily used, can be an exception to the Java naming conventions, using short (1 letter or two) variable names in capital letters. 
 * In this template, constants M and C are used in that form. Some people accept as a good practice also long constant names, all upercase letters, and words separated with underscore (e.g MAX_NUMBER_CONNECTED_ACCESS_NODES).
 * 
 * VARIABLES THAT ARE CONSTANTS:
 * - Use the "final" keyword when a created variable is actually a constant that will not change during its existence in the code. This informs 
 * other developers looking t your code that they are constants, and makes the code more readable (additionally, the Java compiler can make some optimizations that can make your code to be a little bit faster)
 * 
 * USE LESS LINES OF CODE:
 * - A code that makes the job with less lines of code, is more readable, simpler to maintain, better. This can be achieved by structuring the code well. 
 * Also, by re-using the built-in libraries that Java provides, instead of writing ourselves a code for simple things that typically are already implemented there. 
 * Reusing code of these libraries is always better than "re-invent the wheel", coding again what is already there. E.g. use intelligently the 
 * functionalities of the List, Set and Map containers of Java:
 * - A Java List (of type ArrayList, LinkedList,...) is an ordered sequence of elements, same element can appear more than once.
 * - A Java Set (a HashSet, a TreeSet...) is an unordered set of elements, if any element is added twice, the second addition is ignored
 * - A Java Map (HashMap, TreeMap,...) is a set of entries [key , value]. When adding two entries with the same key, the last removes any previous one.   
 * 
 * COMMENTING THE CODE:
 * - By using a structured code, with expressive variable names, your code can be read "like a book". Therefore, it should not need many comments. 
 * Just add the right amount of comments. For this, google "best practices commenting code" and read a bit
 * 
 * REFACTORING:
 * - Use Eclipse options for code refactoring. Read about this NOW!! (e.g https://www.baeldung.com/eclipse-refactoring).
 *  The more you use these options, the more time you save. This saves tons of time. No serious coding can be done without this.
 *  
 * INDENTATION AND CODE FORMATTING:
 * - Eclipse (and other IDEs) provide powerful tools to reindent and reformat the code, so it follows Java conventions. USE THEM! READ NOW ABOUT THEM!
 * (e.g. Google "eclipse java code formatting"). No serious coding can be done without this.
 * 
 * FINAL LEMMA, THE BEST ADVICE I CAN GIVE: There are different opinions on how a well-structured code is, well documented, etc etc. 
 * You are encouraged to read about this in Internet sources, and accept what experienced programmers suggest about this. Please, also 
 * read about what your IDE (e.g. Eclipse) can make for you, to make your life simpler, your code better. Will save you TONS of time. 
 * 
 * 
 * 
 * */

/**
 * This is a template for the students, with an skeleton for solving the topology design problem of the use case
 */
public class TopologyDesign_HamzaHmiddouch implements IAlgorithm {

	@Override
	public String executeAlgorithm(NetPlan np, Map<String, String> algorithmParams, Map<String, String> n2pParams) {
		/* Initialize algorithm parameters */
		final double costPerGbps = Double.parseDouble(algorithmParams.get("costPerGbps"));
		final double maxExecTimeSecs = Double.parseDouble(algorithmParams.get("maxExecTimeSecs"));

		/* Main loop goes here, it */
		np.removeAllLinks(); // remove all links of the input design
		final long algorithmStartTime = System.nanoTime();
		final long algorithmEndTime = algorithmStartTime + (long) (maxExecTimeSecs * 1e9);
		double const_maxSumOfLinkLengths = 0;
		for (Node n1 : np.getNodes())
			for (Node n2 : np.getNodes())
				if (!n1.equals(n2))
					const_maxSumOfLinkLengths += np.getNodePairEuclideanDistance(n1, n2);
		const_maxSumOfLinkLengths *= 100;

		/*To resolve the described problem,I am going to use SAN algorithm.
		 * Typically, the algorithm stores the best solution find so far, which is the one to return when the running time reaches the user-defined
		 * limit
		 */

		List<Node> existingNodes = new ArrayList<>(np.getNodes());

		// For SAN we need a initial solution

		for (int i = 0; i < existingNodes.size() - 1; i++)
		{
			np.addLinkBidirectional(existingNodes.get(i), existingNodes.get(i + 1), 0, 0, 200000, null);
		}
		np.addLinkBidirectional(existingNodes.get(existingNodes.size() - 1), existingNodes.get(0), 0, 0, 200000, null);

		NetPlan initialSolution = np.copy();
		NetPlan currentSolution = initialSolution;
		DesignEvaluation currentSolution_eval = new DesignEvaluation(initialSolution, costPerGbps, const_maxSumOfLinkLengths);
		double costCurrentSolution = currentSolution_eval.getAugmentedCost();

		NetPlan bestSolutionFoundBySAN = currentSolution;
		DesignEvaluation bestSolutionFoundBySAN_eval = currentSolution_eval;
		double costBestSolutionFoundBySAN = bestSolutionFoundBySAN_eval.getAugmentedCost();

		final Random rng = new Random(1L);
		final double tempInitial = 100;
		double temp = tempInitial;
		int FrozenIterations = 0;
		final int maxNumberofConsecutiveNotJump = 150;

		// SAN_Algorithm

		do
		{ // first loop

			// we need to make sure our SAN_Algorithm is not frozen
			if (FrozenIterations >= maxNumberofConsecutiveNotJump)
			{
				temp = tempInitial;
				FrozenIterations = 0;
			}

			for (int i = 0; i < 1000; i++)
			{ // Second loop

				Collections.shuffle(existingNodes, rng);
				Node randomNode1 = np.getNode(rng.nextInt(np.getNumberOfNodes() - 1));
				Node randomNode2 = np.getNode(rng.nextInt(np.getNumberOfNodes() - 1));

				if (randomNode1.getIndex() <= randomNode2.getIndex())
					continue;

				/* Get links */
				final Set<Link> nodePairLinks = np.getNodePairLinks(randomNode2, randomNode1, true);
				if (nodePairLinks.size() != 0 && nodePairLinks.size() != 2)
					throw new RuntimeException("Bad");
				final boolean existsLink = nodePairLinks.size() == 2;

				if (existsLink)
				{
					// The current design has links,we need the construction of the neighbour
					// solution
					final Link n1n2 = np.getNodePairLinks(randomNode1, randomNode2, false).first();
					final Link n2n1 = np.getNodePairLinks(randomNode2, randomNode1, false).first();
					n1n2.remove();
					n2n1.remove();

					final DesignEvaluation randomNeighbour_eval = new DesignEvaluation(np, costPerGbps, const_maxSumOfLinkLengths);
					double costNeighbourSolution = randomNeighbour_eval.getAugmentedCost();

					if (costNeighbourSolution == costCurrentSolution)
						FrozenIterations++; // there is a frozen situation if our current solution does not change
					// Need to check if the random solution improves out current solution
					if (costNeighbourSolution < costCurrentSolution)
					{
						costCurrentSolution = costNeighbourSolution;

						// lets check if the neighbour improves the bestSolution
						if (costNeighbourSolution < costBestSolutionFoundBySAN)
						{
							bestSolutionFoundBySAN = np.copy(); // update the Net2Plan Object
							costBestSolutionFoundBySAN = costCurrentSolution;
							FrozenIterations = 0; // we have improved the solution so we need to restart the counter for frozen situation

						}
					} else
					{
						// There is a possibility of jumping to worse solutions,only we update the cost of current solution
						boolean isAcceptedSolution = acceptSolution(costCurrentSolution, costNeighbourSolution, temp, rng);

						if (isAcceptedSolution)
						{
							costCurrentSolution = costNeighbourSolution;
						} else
						{
							np.addLinkBidirectional(randomNode1, randomNode2, 0, 0, 200000, null);
						}

					}

				}

				else
				{
					// The current design has no links,we need the construction of the neighbour
					// solution
					final Link n1n2 = np.addLink(randomNode1, randomNode2, 0, 0, 200000, null);
					final Link n2n1 = np.addLink(randomNode2, randomNode1, 0, 0, 200000, null);
					final DesignEvaluation randomNeighbour_eval = new DesignEvaluation(np, costPerGbps, const_maxSumOfLinkLengths);

					double costNeighbourSolution = randomNeighbour_eval.getAugmentedCost();
					if (costNeighbourSolution == costCurrentSolution)
						FrozenIterations++; // there is a frozen situation if our current solution does not change

					// Need to check if the random solution improves out current solution
					if (costNeighbourSolution < costCurrentSolution)
					{
						costCurrentSolution = costNeighbourSolution;
						// lets check if the neighbour improves the bestSolution
						if (costNeighbourSolution < costBestSolutionFoundBySAN)
						{
							bestSolutionFoundBySAN = np.copy();// update the Net2Plan Object
							costBestSolutionFoundBySAN = costNeighbourSolution;
							FrozenIterations = 0;// we have improved the solution so we need to restart the counter for frozen situation
						}
					} else
					{
						// There is a possibility of jumping to worse solutions,only we update the cost of current solution
						boolean isAcceptedSolution = acceptSolution(costCurrentSolution, costNeighbourSolution, temp, rng);

						if (isAcceptedSolution)
						{
							costCurrentSolution = costNeighbourSolution;
						} else
						{
							n1n2.remove();
							n2n1.remove();
						}

					}

				}
			}
			temp *= 0.9;

		} while (System.nanoTime() < algorithmEndTime);

		/* Return the solution in bestSolutioFoundByTheAlgorithm */
		final double totalRunningTimeInSeconds = (System.nanoTime() - algorithmStartTime) / 1e9;
		np.assignFrom(bestSolutionFoundBySAN); // this line is for storing in the np variable (the design to
		// return), the best solution found
		final DesignEvaluation returnedDesignInfo = new DesignEvaluation(np, costPerGbps, const_maxSumOfLinkLengths); // computes
		// the
		// design
		// validity
		// (boolean),
		// cost
		// (double)
		// and
		// amount
		// of
		// blocked
		// traffic
		// (double)

		return (returnedDesignInfo.isOk() ? "Correct design" : "Design ERROR") + ". Info: " + returnedDesignInfo + ". Total running time (seconds): "
				+ totalRunningTimeInSeconds;
	}

	public static boolean acceptSolution(double currentSolution_eval, double randomNeighbour_eval, double temperature, Random rnd) {

		final double probabilityJumping = Math.exp(-(randomNeighbour_eval - currentSolution_eval) / temperature);
		return rnd.nextDouble() < probabilityJumping;
	}

	@Override
	public String getDescription() {
		return "This algorithm is a template for developing the topology design . Please, use it!";
	}

	@Override
	public List<Triple<String, String, String>> getParameters() {
		final List<Triple<String, String, String>> res = new ArrayList<>();
		res.add(Triple.of("costPerGbps", "10.0", "The link cost per Gbps associated to link capacity"));
		res.add(Triple.of("maxExecTimeSecs", "60", "Maximum running time of the algorithm."));
		return res;
	}

	/**
	 * This class provides information coming from the evaluation of a case study solution
	 */
	public static class DesignEvaluation {
		private final double input_costPerGbps;
		private final double const_maxSumOfLinkLengths;
		private double const_totalOfferedTrafficGbps = 0;
		private final int E_unidi;

		private double out_totalDistanceOfLinksKm = 0.0;
		private double out_totalLinkCapacity = 0.0;
		private int out_numCutNodes = 0;
		private int out_numConnectedComponents = 0;
		private int out_numDemandsBlocked = 0;

		public DesignEvaluation(NetPlan np, double input_costPerGbps, double const_maxSumOfLinkLengths) {
			this.input_costPerGbps = input_costPerGbps;
			this.const_maxSumOfLinkLengths = const_maxSumOfLinkLengths;
			this.E_unidi = np.getNumberOfLinks();

			final Graph<Node, Link> graph = new DefaultUndirectedWeightedGraph<>(Link.class);
			for (Node n : np.getNodes())
				graph.addVertex(n);
			this.out_totalDistanceOfLinksKm = 0.0;
			for (Link e : np.getLinks())
			{
				final Node n1 = e.getOriginNode();
				final Node n2 = e.getDestinationNode();
				if (n1.getIndex() > n2.getIndex())
					continue;
				if (np.getNodePairLinks(n2, n1, false).size() != 1)
					throw new Net2PlanException("Error. The topology is not bidirectional");
				if (graph.containsEdge(e))
					throw new Net2PlanException("Error. The topology has parallel links");
				final double lengthKm = np.getNodePairEuclideanDistance(n1, n2);
				graph.addEdge(e.getOriginNode(), e.getDestinationNode(), e);
				graph.setEdgeWeight(e, lengthKm);
				this.out_totalDistanceOfLinksKm += 2 * lengthKm;
			}
			/*
			 * this implements internally the Floyd-Warshal algorithm for computing the all-pairs shortest path
			 */
			final FloydWarshallShortestPaths<Node, Link> spCalculator = new FloydWarshallShortestPaths<>(graph);
			this.out_numDemandsBlocked = 0;
			for (Demand d : np.getDemands())
			{
				const_totalOfferedTrafficGbps += d.getOfferedTraffic();
				final Node n1 = d.getIngressNode();
				final Node n2 = d.getEgressNode();
				final GraphPath<Node, Link> path = spCalculator.getPath(n1, n2);
				if (path == null) // no path from n1 to n2 => the design is invalid, the traffic demand n1->n2 is
					// blocked
					this.out_numDemandsBlocked++;
				else // we have a path: we need capacity in all the links traversed by the path
				{
					out_totalLinkCapacity += path.getLength() * d.getOfferedTraffic();
				}
			}
			final BiconnectivityInspector<Node, Link> biconnectInspector = new BiconnectivityInspector<>(graph);
			this.out_numCutNodes = biconnectInspector.getCutpoints().size();
			this.out_numConnectedComponents = biconnectInspector.getConnectedComponents().size();
		}

		/* Returns true if the solution passes the problem constraints */
		public boolean isOk() {
			return out_numCutNodes == 0 && out_numDemandsBlocked == 0 && out_numConnectedComponents == 1;
		}

		/* Returns the sum in km of the lengths of the links */
		public double getSumOfLinkLengths() {
			return this.out_totalDistanceOfLinksKm;
		}

		/*
		 * Returns true is this solution evaluation, corresponds to a solution that is strictly better the one in "other"
		 */
		public boolean isStrictlyBetterThan(DesignEvaluation other) {
			if (this.out_numDemandsBlocked < other.out_numDemandsBlocked)
				return true;
			if (this.out_numDemandsBlocked > other.out_numDemandsBlocked)
				return false;
			if (this.out_numConnectedComponents < other.out_numConnectedComponents)
				return true;
			if (this.out_numConnectedComponents > other.out_numConnectedComponents)
				return false;
			if (this.out_numCutNodes < other.out_numCutNodes)
				return true;
			if (this.out_numCutNodes > other.out_numCutNodes)
				return false;
			return this.getCost() < other.getCost();
		}

		/*
		 * Returns the part of the cost of the network associated to the link capacities
		 */
		public double getCost_capacityPart() {
			return input_costPerGbps * out_totalLinkCapacity;
		}

		/*
		 * Returns the part of the cost of the network associated to the lengths of the links
		 */
		public double getCost_distancePart() {
			return out_totalDistanceOfLinksKm;
		}

		/* Returns the total cost of the network */
		public double getCost() {
			return this.out_totalDistanceOfLinksKm + input_costPerGbps * out_totalLinkCapacity;
		}

		/*
		 * Returns a measure of a so-called "augmented cost". This equals to the regular network cost, plus extra cost penalizations if the solution
		 * does not meet the constraints
		 */
		public double getAugmentedCost() // a penalization is added for i) more blocked demands (should be zero), 2)
		// more connected componnets (should be one, to have a connected topology),
		// 3) more cut nodes (should be zero to be biconnected topology)
		{
			final double maxCostOfAnySolution = (E_unidi / 2) * const_totalOfferedTrafficGbps + const_maxSumOfLinkLengths;
			return getCost() + // max of this summand is maxCostOfAnySolution
					(this.out_numDemandsBlocked + this.out_numCutNodes + (this.out_numConnectedComponents - 1)) * maxCostOfAnySolution;
			// a solution with one extra blocked demand or one more connected components or
			// one more cut node is always worse whatever the link lengths
		}

		/* A useful string describing some info of this solution evaluation */
		public String toString() {
			return "#BidiLinks: " + (this.E_unidi / 2)
					+ (this.isOk()
							? " [Ok] Cost: " + this.getCost()
									+ (" [% capacity part: " + 100.0 * (input_costPerGbps * out_totalLinkCapacity) / getCost() + "]")
							: " [Fail] " + "[Augmented cost: " + this.getAugmentedCost() + "]"
									+ (this.out_numDemandsBlocked == 0 ? "" : "[#Blocked: " + this.out_numDemandsBlocked + "]")
									+ (this.out_numCutNodes == 0 ? "" : "[#Cut nodes: " + this.out_numCutNodes + "]"));
		}
	}

}
