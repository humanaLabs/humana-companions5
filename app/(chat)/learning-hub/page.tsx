import { auth } from "@/app/(auth)/auth";
import { GraduationCapIcon } from "@/components/icons";

export default async function LearningHubPage() {
  const session = await auth();

  return (
    <div className="flex h-dvh w-full flex-col items-center justify-center gap-6 bg-background p-4">
      <div className="flex flex-col items-center gap-4 text-center">
        <div className="text-foreground">
          <GraduationCapIcon size={64} />
        </div>

        <div className="flex flex-col gap-2">
          <h1 className="font-semibold text-2xl">Learning Hub</h1>
          <p className="text-muted-foreground text-sm">
            Esta funcionalidade está em construção
          </p>
        </div>

        <div className="mt-4 flex flex-col gap-2 text-muted-foreground text-xs">
          <p>🚧 Em breve você poderá:</p>
          <ul className="list-inside list-disc text-left">
            <li>Acessar tutoriais e guias de aprendizado</li>
            <li>Explorar cursos e materiais educacionais</li>
            <li>Acompanhar seu progresso de aprendizado</li>
            <li>Participar de desafios e exercícios práticos</li>
          </ul>
        </div>

        {session?.user && (
          <p className="mt-6 text-muted-foreground text-xs">
            Olá, {session.user.email}! Estamos preparando conteúdo para você.
          </p>
        )}
      </div>
    </div>
  );
}
