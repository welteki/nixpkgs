{ lib
, buildGoModule
, fetchFromGitHub
, makeWrapper
, bash
, openssh
}:

buildGoModule rec {
  pname = "k3sup";
  version = "0.11.3";

  src = fetchFromGitHub {
    owner = "alexellis";
    repo = "k3sup";
    rev = version;
    sha256 = "sha256-6WYUmC2uVHFGLsfkA2EUOWmmo1dSKJzI4MEdRnlLgYY=";
  };

  buildInputs = [ makeWrapper ];

  overrideModAttrs = (_: {
    postBuild = ''
      substituteInPlace vendor/github.com/alexellis/go-execute/pkg/v1/exec.go \
        --replace "/bin/bash" "bash"
    '';
  });

  vendorSha256 = "sha256-VT1Xz1FOPy5fW7p4qskYJzmS7xaXt4mlMLkoHpzHMq0=";

  CGO_ENABLED = 0;

  ldflags = [
    "-s" "-w"
    "-X github.com/alexellis/k3sup/cmd.GitCommit=ref/tags/${version}"
    "-X github.com/alexellis/k3sup/cmd.Version=${version}"
  ];

  postInstall = ''
    wrapProgram "$out/bin/k3sup" \
      --prefix PATH : ${lib.makeBinPath [ openssh bash ]}
  '';

  meta = with lib; {
    homepage = "https://github.com/alexellis/k3sup";
    description = "Bootstrap Kubernetes with k3s over SSH";
    license = licenses.mit;
    maintainers = with maintainers; [ welteki ];
    platforms = [
      "x86_64-linux"
      "x86_64-darwin"
      "aarch64-linux"
      "aarch64-darwin"
      "armv7l-linux"
      "armv6l-linux"
    ];
  };
}
