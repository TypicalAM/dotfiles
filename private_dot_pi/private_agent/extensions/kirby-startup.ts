import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

// This is deliberately drawn with terminal cells rather than relying on image
// support, so it also works over SSH and in terminals without Kitty graphics.
const FRAME_MS = 80;
const ANSI_RESET = "\x1b[39m";

type Pixel = {
	char: string;
	color: string;
};

const EMPTY: Pixel = { char: " ", color: "" };

function rgb(red: number, green: number, blue: number): string {
	return `\x1b[38;2;${red};${green};${blue}m`;
}

function lerp(start: number, end: number, amount: number): number {
	return Math.round(start + (end - start) * amount);
}

function pinkShade(light: number): string {
	const t = Math.max(0, Math.min(1, light));
	return rgb(lerp(145, 255, t), lerp(43, 169, t), lerp(111, 215, t));
}

function put(canvas: Pixel[][], x: number, y: number, pixel: Pixel): void {
	if (y >= 0 && y < canvas.length && x >= 0 && x < canvas[0]!.length) {
		canvas[y]![x] = pixel;
	}
}

function ellipse(
	canvas: Pixel[][],
	centerX: number,
	centerY: number,
	radiusX: number,
	radiusY: number,
	pixel: (x: number, y: number, distance: number) => Pixel,
): void {
	const left = Math.floor(centerX - radiusX);
	const right = Math.ceil(centerX + radiusX);
	const top = Math.floor(centerY - radiusY);
	const bottom = Math.ceil(centerY + radiusY);

	for (let y = top; y <= bottom; y++) {
		for (let x = left; x <= right; x++) {
			const dx = (x - centerX) / radiusX;
			const dy = (y - centerY) / radiusY;
			const distance = dx * dx + dy * dy;
			if (distance <= 1) put(canvas, x, y, pixel(x, y, distance));
		}
	}
}

function drawKirby(width: number, elapsedMs: number): string[] {
	// Keep every line within the exact width supplied by the TUI, including on
	// a narrow split or a resized SSH terminal.
	if (width < 24) return ["KIRBY".slice(0, Math.max(0, width))];

	// A large header is intentional: it leaves the normal editor/footer at the
	// bottom while the welcome screen is idle, like Amp's home screen.
	const canvasWidth = Math.min(72, width - 2);
	const canvasHeight = canvasWidth >= 50 ? 29 : 23;
	const canvas: Pixel[][] = Array.from({ length: canvasHeight }, () =>
		Array.from({ length: canvasWidth }, () => EMPTY),
	);
	const centerX = (canvasWidth - 1) / 2;
	const centerY = canvasHeight >= 29 ? 13 : 10;
	const bodyRadiusX = Math.min(19, Math.max(8, canvasWidth * 0.27));
	const bodyRadiusY = Math.min(canvasHeight >= 29 ? 10 : 8, bodyRadiusX * 0.6);

	// Keep turning until the user starts typing. The front, side, and back
	// silhouettes remain readable instead of flashing by.
	const angle = elapsedMs / 410;
	const yaw = Math.sin(angle);
	// Keep the sign of cosine: using its absolute value made the front face
	// appear again on the rear half-turn, which looked like a side-to-side sway.
	const front = Math.max(0, Math.cos(angle));
	const back = Math.max(0, -Math.cos(angle));
	const featureScale = 0.12 + 0.88 * front;
	const faceX = centerX + yaw * bodyRadiusX * 0.35;
	const bodyBottom = centerY + bodyRadiusY;

	// A quiet star field makes this feel like a background, while remaining
	// deterministic so resize/rerender does not make the stars jump around.
	const stars = [
		[2, 2, "+"], [8, canvasHeight - 5, "·"], [14, 3, "·"],
		[canvasWidth - 5, 3, "+"], [canvasWidth - 10, canvasHeight - 6, "·"],
		[canvasWidth - 2, Math.round(centerY), "·"], [4, Math.round(centerY), "·"],
	] as const;
	for (const [x, y, char] of stars) {
		put(canvas, x, y, { char, color: rgb(98, 91, 157) });
	}

	// Ground shadow, then Kirby's feet/hands, then his round body. Layering is
	// what keeps the 3-D figure legible at small terminal sizes.
	ellipse(canvas, centerX, canvasHeight - 1.1, bodyRadiusX * 0.85, 0.7, () => ({
		char: "▄",
		color: rgb(57, 44, 85),
	}));
	const footSpread = bodyRadiusX * (0.47 + front * 0.08);
	const footRadiusX = bodyRadiusX * 0.35;
	const footRadiusY = Math.max(1.5, bodyRadiusY * 0.25);
	ellipse(canvas, centerX - footSpread, bodyBottom + 1.1, footRadiusX, footRadiusY, () => ({
		char: "█",
		color: rgb(210, 48, 75),
	}));
	ellipse(canvas, centerX + footSpread, bodyBottom + 1.1, footRadiusX, footRadiusY, () => ({
		char: "█",
		color: rgb(210, 48, 75),
	}));
	const handRadiusX = bodyRadiusX * 0.24;
	ellipse(canvas, centerX - bodyRadiusX * 0.93, centerY + 1 - yaw * 1.2, handRadiusX, bodyRadiusY * 0.34, () => ({
		char: "█",
		color: rgb(231, 83, 146),
	}));
	ellipse(canvas, centerX + bodyRadiusX * 0.93, centerY + 1 + yaw * 1.2, handRadiusX, bodyRadiusY * 0.34, () => ({
		char: "█",
		color: rgb(231, 83, 146),
	}));

	// Sphere shading gives the body volume. The moving highlight sells the yaw
	// rotation even though this is rendered in a 2-D terminal grid.
	ellipse(canvas, centerX, centerY, bodyRadiusX, bodyRadiusY, (x, y, distance) => {
		const dx = (x - centerX) / bodyRadiusX;
		const dy = (y - centerY) / bodyRadiusY;
		const depth = Math.sqrt(Math.max(0, 1 - distance));
		const light = 0.36 + depth * 0.34 - dx * 0.17 * Math.cos(angle) - dy * 0.17 + yaw * 0.05 - back * 0.06;
		return { char: "█", color: pinkShade(light) };
	});

	// Features only exist on the front-facing hemisphere. They disappear as
	// Kirby turns edge-on and stay hidden while his back is toward us; this is
	// the important difference between a full 360-degree turn and a sway.
	if (front > 0.02) {
		const eyeY = centerY - bodyRadiusY * 0.3;
		const eyeGap = bodyRadiusX * 0.21 * featureScale;
		for (const eyeX of [faceX - eyeGap, faceX + eyeGap]) {
			ellipse(canvas, eyeX, eyeY, bodyRadiusX * 0.065 * featureScale + 0.18, bodyRadiusY * 0.23, () => ({
				char: "█",
				color: rgb(35, 20, 43),
			}));
			put(canvas, Math.round(eyeX), Math.round(eyeY - bodyRadiusY * 0.12), {
				char: "█",
				color: rgb(255, 244, 250),
			});
		}

		// Cheeks follow the face as it turns, like the features are painted on
		// the sphere rather than floating in front of it.
		const cheekGap = bodyRadiusX * 0.41 * featureScale;
		const cheekY = centerY + bodyRadiusY * 0.1;
		ellipse(canvas, faceX - cheekGap, cheekY, bodyRadiusX * 0.13 * featureScale + 0.25, bodyRadiusY * 0.1, () => ({
			char: "█",
			color: rgb(236, 61, 107),
		}));
		ellipse(canvas, faceX + cheekGap, cheekY, bodyRadiusX * 0.13 * featureScale + 0.25, bodyRadiusY * 0.1, () => ({
			char: "█",
			color: rgb(236, 61, 107),
		}));

		// The mouth is an actual open cavity, not a line: burgundy rim, black
		// interior, and a red tongue. At the side angle it naturally compresses.
		const mouthY = centerY + bodyRadiusY * 0.43;
		const mouthRadiusX = bodyRadiusX * 0.25 * featureScale + 0.5;
		ellipse(canvas, faceX, mouthY, mouthRadiusX, bodyRadiusY * 0.28, () => ({
			char: "█",
			color: rgb(83, 20, 59),
		}));
		ellipse(canvas, faceX, mouthY + 0.15, Math.max(0.7, mouthRadiusX - 0.9), bodyRadiusY * 0.19, () => ({
			char: "█",
			color: rgb(25, 10, 28),
		}));
		ellipse(canvas, faceX, mouthY + bodyRadiusY * 0.1, Math.max(0.55, mouthRadiusX - 1.1), bodyRadiusY * 0.075, () => ({
			char: "▀",
			color: rgb(242, 89, 122),
		}));
	}


	const blank = " ".repeat(Math.max(0, Math.floor((width - canvasWidth) / 2)));
	const colored = (pixel: Pixel): string => pixel.color ? `${pixel.color}${pixel.char}${ANSI_RESET}` : pixel.char;
	return canvas.map((row) => blank + row.map(colored).join(""));
}

export default function (pi: ExtensionAPI): void {
	let stopAnimation: (() => void) | undefined;

	pi.on("session_start", (_event, ctx) => {
		if (ctx.mode !== "tui") return;

		ctx.ui.setHeader((tui, _theme) => {
			const startedAt = Date.now();
			let dismissed = false;
			let stopped = false;
			const timer = setInterval(() => {
				if (!dismissed) tui.requestRender();
			}, FRAME_MS);
			const stop = () => {
				if (stopped) return;
				stopped = true;
				clearInterval(timer);
			};

			stopAnimation = stop;
			return {
				render(width: number): string[] {
					// Keep the large welcome animation until the user begins their
					// first prompt; after that, leave the transcript uncluttered.
					if (dismissed) return [];
					if (ctx.ui.getEditorText().length > 0) {
						dismissed = true;
						stop();
						return [];
					}
					return drawKirby(width, Date.now() - startedAt);
				},
				invalidate(): void {},
			};
		});
	});

	pi.on("session_shutdown", () => {
		stopAnimation?.();
		stopAnimation = undefined;
	});
}
