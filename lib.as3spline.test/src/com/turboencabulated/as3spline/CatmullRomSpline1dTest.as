package com.turboencabulated.as3spline
{
	import org.flexunit.asserts.assertEquals;
	import org.flexunit.asserts.assertTrue;

	public class CatmullRomSpline1dTest
	{

		[Before]
		public function setUp() : void
		{
		}

		[After]
		public function tearDown() : void
		{
		}

		[BeforeClass]
		public static function setUpBeforeClass() : void
		{
		}

		[AfterClass]
		public static function tearDownAfterClass() : void
		{
		}

		private function assertFloatEquals(expected : Number, actual : Number, epsilon : Number = 0.0001) : void
		{
			if (Math.abs(expected - actual) > epsilon)
			{
				assertTrue("Float expected=" + expected + " actual=" + actual, false);
			}
		}

		[Test]
		public function testEquivalenceLine() : void
		{
			var points : Vector.<Number> = new Vector.<Number>();
			points.push(0);
			points.push(0);
			points.push(0);
			points.push(0);

			var crs : CatmullRomSpline1d;
			var v : Number = 0;

			// first try with implicit uniform parameterization
			crs = new CatmullRomSpline1d(points, null);

			v = crs.sample(0);
			assertFloatEquals(0, v);

			v = crs.sample(0.5);
			assertFloatEquals(0, v);

			v = crs.sample(1.0);
			assertFloatEquals(0, v);

			var lengths : Vector.<Number> = new Vector.<Number>();
			lengths.push(1);
			lengths.push(1);
			lengths.push(1);

			// now try with explicit uniform parameterization
			crs = new CatmullRomSpline1d(points, lengths);

			v = crs.sample(0);
			assertFloatEquals(0, v);

			v = crs.sample(0.5);
			assertFloatEquals(0, v);

			v = crs.sample(1.0);
			assertFloatEquals(0, v);
		}

		[Test]
		public function testProportionalLine() : void
		{
			var points : Vector.<Number> = new Vector.<Number>();
			points.push(-1);
			points.push(0);
			points.push(1);
			points.push(2);

			var crs : CatmullRomSpline1d;
			var v : Number = 0;

			// first try with implicit uniform parameterization
			crs = new CatmullRomSpline1d(points, null);

			v = crs.sample(0);
			assertFloatEquals(0, v);

			v = crs.sample(0.5);
			assertFloatEquals(0.5, v);

			v = crs.sample(1.0);
			assertFloatEquals(1.0, v);

			var lengths : Vector.<Number> = new Vector.<Number>();
			lengths.push(1);
			lengths.push(1);
			lengths.push(1);

			// now try with explicit uniform parameterization
			crs = new CatmullRomSpline1d(points, lengths);

			v = crs.sample(0);
			assertFloatEquals(0, v);

			v = crs.sample(0.5);
			assertFloatEquals(0.5, v);

			v = crs.sample(1.0);
			assertFloatEquals(1.0, v);
		}

		[Test]
		public function testNonUniformProportionalLine() : void
		{
			var points : Vector.<Number> = new Vector.<Number>();
			points.push(-1);
			points.push(0);
			points.push(0.3);
			points.push(1);
			points.push(2);

			var lengths : Vector.<Number> = new Vector.<Number>();
			lengths.push(1);
			lengths.push(0.3);
			lengths.push(0.7);
			lengths.push(1);

			var crs : CatmullRomSpline1d = new CatmullRomSpline1d(points, lengths);
			var v : Number = 0;

			v = crs.sample(0);
			assertFloatEquals(0, v);

			v = crs.sample(0.5);
			assertFloatEquals(0.5, v);

			v = crs.sample(1.0);
			assertFloatEquals(1.0, v);
		}

	}
}
