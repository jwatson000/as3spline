package com.turboencabulated.as3spline
{
	import flash.geom.Point;

	import org.flexunit.asserts.assertEquals;
	import org.flexunit.asserts.assertTrue;

	public class CatmullRomSpline2dTest
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
			var points : Vector.<Point> = new Vector.<Point>();
			points.push(new Point(-1, 0));
			points.push(new Point(0, 0));
			points.push(new Point(1, 0));
			points.push(new Point(2, 0));

			var crs : CatmullRomSpline2d = new CatmullRomSpline2d(points);
			assertFloatEquals(1, crs.totalLength);
			var v : Point = new Point();

			crs.sample(0, v);
			assertFloatEquals(0, v.x);
			assertFloatEquals(0, v.y);

			crs.sample(0.5, v);
			assertFloatEquals(0.5, v.x);
			assertFloatEquals(0, v.y);

			crs.sample(1.0, v);
			assertFloatEquals(1.0, v.x);
			assertFloatEquals(0, v.y);
		}

		[Test]
		public function testProportionalLine() : void
		{
			var points : Vector.<Point> = new Vector.<Point>();
			points.push(new Point(-1, -1));
			points.push(new Point(0, 0));
			points.push(new Point(1, 1));
			points.push(new Point(2, 2));

			var crs : CatmullRomSpline2d = new CatmullRomSpline2d(points);
			assertFloatEquals(Math.sqrt(2), crs.totalLength);
						
			var v : Point = new Point();

			crs.sample(0, v);
			assertFloatEquals(0, v.x);
			assertFloatEquals(0, v.y);

			crs.sample(0.5, v);
			assertFloatEquals(0.5, v.x);
			assertFloatEquals(0.5, v.y);

			crs.sample(1.0, v);
			assertFloatEquals(1.0, v.x);
			assertFloatEquals(1.0, v.y);
		}

		[Test]
		public function testNonUniformProportionalLine() : void
		{
			var points : Vector.<Point> = new Vector.<Point>();
			points.push(new Point(-1, -1));
			points.push(new Point(0, 0));
			points.push(new Point(0.1, 0.1));
			points.push(new Point(1, 1));
			points.push(new Point(2, 2));

			var crs : CatmullRomSpline2d = new CatmullRomSpline2d(points);
			assertFloatEquals(Math.sqrt(2), crs.totalLength);
			var v : Point = new Point();

			crs.sample(0, v);
			assertFloatEquals(0, v.x);
			assertFloatEquals(0, v.y);

			crs.sample(0.5, v);
			assertFloatEquals(0.5, v.x);
			assertFloatEquals(0.5, v.y);

			crs.sample(1.0, v);
			assertFloatEquals(1.0, v.x);
			assertFloatEquals(1.0, v.y);
		}

	}
}
