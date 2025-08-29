import os
import ffmpeg
import yt_dlp


def cut_youtube(url: str, initial: str | None = None, final: str | None = None) -> bytes:
    """
    Download a YouTube video, cut it between initial and final timestamps,
    and return the binary content.

    Args:
        url (str): YouTube video link.
        initial (str | None): Start timestamp in HH:MM:SS (optional).
        final (str | None): End timestamp in HH:MM:SS (optional).

    Returns:
        bytes: Binary content of the processed video in MP4 format.
    """

    # 1. Criar pasta media/
    media_dir = os.path.join(os.path.dirname(__file__), "media")
    os.makedirs(media_dir, exist_ok=True)

    input_path = os.path.join(media_dir, "input.mp4")
    output_path = os.path.join(media_dir, "output.mp4")

    try:
        # 2. Download com yt-dlp
        print(f"# Download video com yt-dlp: {url}")
        ydl_opts = {
            "outtmpl": input_path,
            "format": "mp4/bestvideo+bestaudio/best",
            "merge_output_format": "mp4",
            "quiet": True,
        }
        with yt_dlp.YoutubeDL(ydl_opts) as ydl:
            ydl.download([url])

        # 3. Preparar corte com ffmpeg
        print(f"# Executando corte de {initial or '0'} até {final or 'EOF'}")
        kwargs = {}
        if initial:
            kwargs["ss"] = initial
        if final:
            kwargs["to"] = final

        (
            ffmpeg
            .input(input_path, **kwargs)
            .output(output_path, c="copy")  # copy = rápido (sem reencode)
            .overwrite_output()
            .run(quiet=True)
        )

        # 4. Ler resultado como binário
        print("# Lendo arquivo de saída...")
        with open(output_path, "rb") as f:
            video_bytes = f.read()

        return video_bytes

    except Exception as e:
        print(f"Error processing video: {e}")
        raise

    finally:
        # 5. Limpeza
        if os.path.exists(input_path):
            os.remove(input_path)
        if os.path.exists(output_path):
            os.remove(output_path)
