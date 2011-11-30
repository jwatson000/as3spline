package com.turboencabulated.as3spline
{

	public class CatmullRomSpline1d
	{
		private var points : Vector.<Number> = new Vector.<Number>();
		private var parameters : Vector.<Number>;
		public var totalLength : Number = 0;

		public function CatmullRomSpline1d(points : Vector.<Number>, lengths : Vector.<Number>)
		{
			if (points.length < 4)
			{
				throw new ArgumentError("4 or more points are required for a catmull-rom spline");
			}

			this.points = points;

			if (lengths)
			{
				createParameters(lengths);
			}
		}

		private function createParameters(lengths : Vector.<Number>) : void
		{
			// normalize the lengths

			if (lengths.length != (points.length - 1))
			{
				throw new ArgumentError("There must be one fewer lengths than points");
			}

			totalLength = 0;
			var i : int;

			// quick sanity check
			for (i = 0; i < lengths.length; ++i)
			{
				if (lengths[i] <= 0)
				{
					throw new ArgumentError("lengths must be positive, hombre");
				}
			}

			parameters = new Vector.<Number>();

			// leadin placeholder
			parameters.push(-1);

			// don't count the leadin and leadout as part of the total length for interpolation

			for (i = 1; i < (lengths.length - 1); ++i)
			{
				parameters.push(totalLength);
				totalLength += lengths[i];
			}

			// normalize the parameters
			for (i = 0; i < parameters.length; ++i)
			{
				parameters[i] = parameters[i] / totalLength;
			}

			parameters.push(1);

			// fixup leadin
			parameters[0] = -lengths[0] / totalLength;

			// setup leadout

			parameters.push(1 + lengths[lengths.length - 1] / totalLength);
		}

		private function uniformSegment(t : Number,
			v0 : Number, v1 : Number, v2 : Number, v3 : Number) : Number
		{
			return segment(t, 1, 1, v0, v1, v2, v3);
		}

		/**
		 *
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
			v0 : Number, v1 : Number, v2 : Number, v3 : Number) : Number
		{
			// shorthand for exponentials of t
			var t2 : Number = (t * t);
			var t3 : Number = t * t2;

			// the hermite basis functions
			var h1 : Number = 2 * t3 - 3 * t2 + 1;
			var h2 : Number = -2 * t3 + 3 * t2;
			var h3 : Number = t3 - 2 * t2 + t;
			var h4 : Number = t3 - t2;

			// catmull-rom splines have a tension of 0.5 by definition
			var tension : Number = 0.5;

			// cardinal spline tangents			
			var m1 : Number = s1 * 0.5 * (v2 - v0);
			var m2 : Number = s2 * 0.5 * (v3 - v1);

			return m1 * h3 + v1 * h1 + v2 * h2 + m2 * h4;
		}

		private function nonUniformSegment(t : Number,
			t0 : Number, t1 : Number, t2 : Number, t3 : Number,
			v0 : Number, v1 : Number, v2 : Number, v3 : Number) : Number
		{
			var dx0 : Number = t2 - t1;
			var dx1 : Number = t1 - t0;
			var dx2 : Number = t3 - t2;

			// cardinal spline scaling factors
			var s1 : Number = 2 * dx0 / (dx1 + dx0);
			var s2 : Number = 2 * dx0 / (dx0 + dx2);

			return segment(t, s1, s2, v0, v1, v2, v3);
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

		public function sample(t : Number) : Number
		{
			if (t <= 0)
			{
				return points[1];
			}

			if (t >= 1)
			{
				return points[points.length - 2];
			}

			var i1 : int = findPointIndex(t);

			if (i1 >= points.length - 2)
			{
				return points[i1];
			}

			var p0 : Number = points[i1 - 1];
			var p1 : Number = points[i1 + 0];
			var p2 : Number = points[i1 + 1];
			var p3 : Number = points[i1 + 2];

			// now how far from p1 to p2 (parameterized)

			var p1t : Number = getPointParameter(i1 + 0);
			var p2t : Number = getPointParameter(i1 + 1);

			var st : Number = (t - p1t) / (p2t - p1t);

			if (!parameters)
			{
				return uniformSegment(st,
					p0, p1, p2, p3);
			}

			var p0t : Number = getPointParameter(i1 - 1);
			var p3t : Number = getPointParameter(i1 + 2);

			return nonUniformSegment(st,
				p0t, p1t, p2t, p3t,
				p0, p1, p2, p3);

		}
	}
}
