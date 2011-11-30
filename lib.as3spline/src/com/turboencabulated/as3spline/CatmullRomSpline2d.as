package com.turboencabulated.as3spline
{
	import flash.geom.Point;

	public class CatmullRomSpline2d
	{
		public var points : Vector.<Point> = new Vector.<Point>();
		internal var parameters : Vector.<Number>;
		public var totalLength : Number = 0;
		// catmull-rom splines have a tension of 0.5 by definition	
		private var m_tension : Number = 0.5;

		public function CatmullRomSpline2d(points : Vector.<Point>, tension : Number = 0.5)
		{
			this.m_tension = tension;

			if (points.length < 4)
			{
				throw new ArgumentError("4 or more points are required for a catmull-rom spline");
			}

			this.points = points;

			parameterize();
		}

		public function get tension() : Number
		{
			return m_tension;
		}

		public function set tension(value : Number) : void
		{
			if (m_tension != value)
			{
				m_tension = value;

				// tension affects the arc-length between points
				parameterize();
			}
		}


		/**
		 * measuring local caceh point
		 */
		private var mp0 : Point = new Point();
		private var mp1 : Point = new Point();

		private function measureSegmentArc(index : int, step : Number) : Number
		{
			var tmp : Point;
			var d : Number = 0;
			
			var p0 : Point = points[index-1];
			var p1 : Point = points[index+0];
			var p2 : Point = points[index+1];
			var p3 : Point = points[index+2];
			
//			// always keep mp0 pointing to the 'previous' point
//			mp0.copyFrom(p1);
//	
//			for (var t : Number = step; t < 1; t += step)
//			{
//				uniformSegment(t, p0, p1, p2, p3, mp1);				
//				d += Point.distance(mp1, mp0);
//				
//				// re-use mp0
//				tmp = mp0;
//				mp0 = mp1;
//				mp1 = tmp;
//			}
//			
//			mp1.copyFrom(p2);
//			d += Point.distance(mp1, mp0);
			
			d = Point.distance(p1, p2);
			
			return d;
		}
		
		/**
		 * Arc-length parameterization
		 *
		 */
		public function parameterize() : void
		{
			parameters = null;
			totalLength = 0;

			var ps : Vector.<Number> = new Vector.<Number>();

			// lead-in length (straight line)
			var leadIn : Number = Point.distance(points[0], points[1]);
			ps.push(-leadIn);

			ps.push(0);

			// always start at zero
			var total : Number = 0;

			var step : Number = 0.1;
			for (var i : int = 1; i < (points.length - 2); ++i)
			{
				var l : Number = measureSegmentArc(i, step);
				total += l;
				ps.push(total);
			}

			// lead-out length (straight line)

			var leadOut : Number = Point.distance(points[points.length - 2], points[points.length - 1]);
			ps.push(total + leadOut);

			// normalize the parameters
			for (i = 0; i < ps.length; ++i)
			{
				ps[i] = ps[i] / total;
			}

			totalLength = total;
			parameters = ps;
		}

		private function uniformSegment(t : Number,
			v0 : Point, v1 : Point, v2 : Point, v3 : Point, out : Point) : Point
		{
			return segment(t, 1, 1, v0, v1, v2, v3, out);
		}

		/**
		 * http://codeplea.com/introduction-to-splines
		 * @param t
		 * @param s1 cardinal spline scaling factor
		 * @param s2 cardinal spline scaling factor
		 * @param P0
		 * @param P1
		 * @param P2
		 * @param P3
		 * @return
		 *
		 */
		private function segment(t : Number,
			s1 : Number, s2 : Number,
			v0 : Point, v1 : Point, v2 : Point, v3 : Point, out : Point) : Point
		{
			// shorthand for exponentials of t
			var t2 : Number = (t * t);
			var t3 : Number = t * t2;

			// the hermite basis functions
			var h1 : Number = 2 * t3 - 3 * t2 + 1;
			var h2 : Number = -2 * t3 + 3 * t2;
			var h3 : Number = t3 - 2 * t2 + t;
			var h4 : Number = t3 - t2;

			// cardinal spline tangents			
			var mx1 : Number = s1 * tension * (v2.x - v0.x);
			var mx2 : Number = s2 * tension * (v3.x - v1.x);

			var my1 : Number = s1 * tension * (v2.y - v0.y);
			var my2 : Number = s2 * tension * (v3.y - v1.y);

			out.x = mx1 * h3 + v1.x * h1 + v2.x * h2 + mx2 * h4;
			out.y = my1 * h3 + v1.y * h1 + v2.y * h2 + my2 * h4;
			return out;
		}

		private function nonUniformSegment(t : Number,
			t0 : Number, t1 : Number, t2 : Number, t3 : Number,
			v0 : Point, v1 : Point, v2 : Point, v3 : Point, out : Point) : Point
		{
			var dx0 : Number = t2 - t1;
			var dx1 : Number = t1 - t0;
			var dx2 : Number = t3 - t2;

			// cardinal spline scaling factors
			var s1 : Number = 2 * dx0 / (dx1 + dx0);
			var s2 : Number = 2 * dx0 / (dx0 + dx2);

			return segment(t, s1, s2, v0, v1, v2, v3, out);
		}

		private function findPointIndex(t : Number) : int
		{
			if (!parameters)
			{
				// uniform parameterization
				return Math.max(1, Math.min(points.length - 2, int(t * (points.length - 2))));
			}

			// piecewise linear parameterization

			for (var i : int = 2; i < parameters.length; ++i)
			{
				if (parameters[i] > t)
				{
					return (i - 1);
				}
			}

			return points.length - 3;
		}

		private function getPointParameter(index : int) : Number
		{
			if (!parameters)
			{
				// uniform parameterization
				return Number(index - 1) / (points.length - 3);
			}

			// piecewise linear parameterization

			return parameters[index];
		}

		public function sample(t : Number, out : Point) : Point
		{
			if (t <= 0)
			{
				out.copyFrom(points[1]);
				return out;
			}

			if (t >= 1)
			{
				out.copyFrom(points[points.length - 2]);
				return out;
			}

			var i1 : int = findPointIndex(t);

			if (i1 >= points.length - 2)
			{
				out.copyFrom(points[i1]);
				return out;
			}

			var p0 : Point = points[i1 - 1];
			var p1 : Point = points[i1 + 0];
			var p2 : Point = points[i1 + 1];
			var p3 : Point = points[i1 + 2];

			// now how far from p1 to p2 (parameterized)

			var p1t : Number = getPointParameter(i1 + 0);
			var p2t : Number = getPointParameter(i1 + 1);

			var st : Number = (t - p1t) / (p2t - p1t);

			if (!parameters)
			{
				return uniformSegment(st,
					p0, p1, p2, p3, out);
			}

			var p0t : Number = getPointParameter(i1 - 1);
			var p3t : Number = getPointParameter(i1 + 2);

			return nonUniformSegment(st,
				p0t, p1t, p2t, p3t,
				p0, p1, p2, p3, out);

		}
	}
}
